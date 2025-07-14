defmodule Deepgram.Speak.WebSocket do
  @moduledoc """
  WebSocket client for live text-to-speech synthesis.

  This module provides a WebSocket client that can connect to Deepgram's
  live text-to-speech service for real-time audio synthesis.
  """

  use WebSockex

  alias Deepgram.Client
  alias Deepgram.Config
  alias Deepgram.Error
  alias Deepgram.Types.Speak

  require Logger

  @type state :: %{
          client: Client.t(),
          options: Speak.speak_ws_options(),
          callback_pid: pid() | nil,
          connected: boolean()
        }

  @api_version "v1"

  @doc """
  Starts a WebSocket connection for live text-to-speech synthesis.

  ## Parameters

  - `client` - A `Deepgram.Client` struct
  - `options` - Live synthesis options
  - `callback_pid` - Optional PID to receive messages (defaults to caller)

  ## Examples

      iex> client = Deepgram.new(api_key: "your-api-key")
      iex> options = %{model: "aura-2-thalia-en", encoding: "linear16"}
      iex> {:ok, websocket} = Deepgram.Speak.WebSocket.start_link(client, options)
      {:ok, #PID<...>}

  """
  @spec start_link(Client.t(), Speak.speak_ws_options(), pid() | nil) ::
          {:ok, pid()} | {:error, any()}
  def start_link(%Client{} = client, options \\ %{}, callback_pid \\ nil) do
    url = build_websocket_url(client, options)
    headers = build_websocket_headers(client)
    callback_pid = callback_pid || self()

    initial_state = %{
      client: client,
      options: options,
      callback_pid: callback_pid,
      connected: false
    }

    WebSockex.start_link(url, __MODULE__, initial_state, extra_headers: headers)
  end

  @doc """
  Sends text to be synthesized to the WebSocket.

  ## Parameters

  - `websocket` - The WebSocket process PID
  - `text` - Text to synthesize to speech

  ## Examples

      iex> Deepgram.Speak.WebSocket.send_text(websocket, "Hello, world!")
      :ok

  """
  @spec send_text(pid(), String.t()) :: :ok
  def send_text(websocket, text) when is_binary(text) do
    message = Jason.encode!(%{type: "Speak", text: text})
    WebSockex.send_frame(websocket, {:text, message})
  end

  @doc """
  Flushes the current synthesis buffer.

  ## Parameters

  - `websocket` - The WebSocket process PID

  ## Examples

      iex> Deepgram.Speak.WebSocket.flush(websocket)
      :ok

  """
  @spec flush(pid()) :: :ok
  def flush(websocket) do
    flush_message = Jason.encode!(%{type: "Flush"})
    WebSockex.send_frame(websocket, {:text, flush_message})
  end

  @doc """
  Clears the current synthesis buffer.

  ## Parameters

  - `websocket` - The WebSocket process PID

  ## Examples

      iex> Deepgram.Speak.WebSocket.clear(websocket)
      :ok

  """
  @spec clear(pid()) :: :ok
  def clear(websocket) do
    clear_message = Jason.encode!(%{type: "Clear"})
    WebSockex.send_frame(websocket, {:text, clear_message})
  end

  @doc """
  Closes the WebSocket connection.

  ## Parameters

  - `websocket` - The WebSocket process PID

  ## Examples

      iex> Deepgram.Speak.WebSocket.close(websocket)
      :ok

  """
  @spec close(pid()) :: :ok
  def close(websocket) do
    close_message = Jason.encode!(%{type: "Close"})
    WebSockex.send_frame(websocket, {:text, close_message})
  end

  # WebSockex callbacks

  @impl WebSockex
  def handle_connect(_conn, state) do
    Logger.info("Connected to Deepgram Live Text-to-Speech")

    new_state = %{state | connected: true}

    # Notify callback process
    send(state.callback_pid, {:deepgram_connected, self()})

    {:ok, new_state}
  end

  @impl WebSockex
  def handle_frame({:text, message}, state) do
    case Jason.decode(message) do
      {:ok, parsed_message} ->
        handle_message(parsed_message, state)

      {:error, reason} ->
        Logger.error("Failed to parse WebSocket message: #{inspect(reason)}")
        error = Error.json_error("Failed to parse WebSocket message", reason)
        send(state.callback_pid, {:deepgram_error, error})
        {:ok, state}
    end
  end

  @impl WebSockex
  def handle_frame({:binary, audio_data}, state) do
    # Handle binary audio data
    send(state.callback_pid, {:deepgram_audio, audio_data})
    {:ok, state}
  end

  @impl WebSockex
  def handle_frame(frame, state) do
    Logger.debug("Received unhandled frame: #{inspect(frame)}")
    {:ok, state}
  end

  @impl WebSockex
  def handle_info(_info, state) do
    {:ok, state}
  end

  @impl WebSockex
  def handle_disconnect(%{reason: reason}, state) do
    Logger.info("Disconnected from Deepgram Live Text-to-Speech: #{inspect(reason)}")

    new_state = %{state | connected: false}

    # Notify callback process
    send(state.callback_pid, {:deepgram_disconnected, reason})

    {:ok, new_state}
  end

  @impl WebSockex
  def terminate(reason, state) do
    Logger.info("WebSocket terminated: #{inspect(reason)}")

    # Notify callback process
    send(state.callback_pid, {:deepgram_terminated, reason})

    :ok
  end

  # Private helper functions

  defp handle_message(%{"type" => "Metadata"} = message, state) do
    send(state.callback_pid, {:deepgram_metadata, message})
    {:ok, state}
  end

  defp handle_message(%{"type" => "Flushed"} = message, state) do
    send(state.callback_pid, {:deepgram_flushed, message})
    {:ok, state}
  end

  defp handle_message(%{"type" => "Cleared"} = message, state) do
    send(state.callback_pid, {:deepgram_cleared, message})
    {:ok, state}
  end

  defp handle_message(%{"type" => "Warning"} = message, state) do
    send(state.callback_pid, {:deepgram_warning, message})
    {:ok, state}
  end

  defp handle_message(%{"type" => "Error"} = message, state) do
    error = Error.websocket_error("WebSocket error", message)
    send(state.callback_pid, {:deepgram_error, error})
    {:ok, state}
  end

  defp handle_message(%{"type" => "Close"} = message, state) do
    send(state.callback_pid, {:deepgram_close, message})
    {:ok, state}
  end

  defp handle_message(%{"type" => "Open"} = message, state) do
    send(state.callback_pid, {:deepgram_open, message})
    {:ok, state}
  end

  defp handle_message(message, state) do
    send(state.callback_pid, {:deepgram_unhandled, message})
    {:ok, state}
  end

  @doc """
  Builds the WebSocket URL for live text-to-speech.
  """
  def build_websocket_url(%Client{config: config}, options) do
    base_url = String.replace(config.base_url, ~r/^https?/, "wss")
    query_params = build_query_params(options)

    case query_params do
      [] -> "#{base_url}/#{@api_version}/speak"
      params -> "#{base_url}/#{@api_version}/speak?#{URI.encode_query(params)}"
    end
  end

  @doc """
  Builds WebSocket headers for authentication.
  """
  def build_websocket_headers(%Client{config: config}) do
    [
      {"Authorization", Config.auth_header(config)},
      {"User-Agent", Config.user_agent()}
    ]
  end

  @doc """
  Builds query parameters for WebSocket URL.
  """
  def build_query_params(options) when is_map(options) do
    options
    |> Enum.reduce([], fn {key, value}, acc ->
      case format_query_param(key, value) do
        {param_key, param_value} -> [{param_key, param_value} | acc]
        nil -> acc
      end
    end)
    |> Enum.reverse()
  end

  defp format_query_param(key, value) when is_list(value) do
    {to_string(key), Enum.join(value, ",")}
  end

  defp format_query_param(key, value) when is_boolean(value) do
    {to_string(key), to_string(value)}
  end

  defp format_query_param(key, value) when is_number(value) do
    {to_string(key), to_string(value)}
  end

  defp format_query_param(key, value) when is_binary(value) do
    {to_string(key), value}
  end

  defp format_query_param(key, value) when is_atom(value) do
    {to_string(key), to_string(value)}
  end

  defp format_query_param(_, _), do: nil
end
