defmodule Deepgram.Listen.WebSocket do
  @moduledoc """
  WebSocket client for live speech-to-text transcription.

  This module provides a WebSocket client that can connect to Deepgram's
  live transcription service for real-time speech-to-text processing.
  """

  use WebSockex

  alias Deepgram.Client
  alias Deepgram.Config
  alias Deepgram.Error
  alias Deepgram.Types.Listen

  require Logger

  @type state :: %{
          client: Client.t(),
          options: Listen.live_options(),
          callback_pid: pid() | nil,
          connected: boolean(),
          keepalive_ref: reference() | nil
        }

  @keepalive_interval 30_000
  @api_version "v1"

  @doc """
  Starts a WebSocket connection for live transcription.

  ## Parameters

  - `client` - A `Deepgram.Client` struct
  - `options` - Live transcription options
  - `callback_pid` - Optional PID to receive messages (defaults to caller)

  ## Examples

      iex> client = Deepgram.new(api_key: "your-api-key")
      iex> options = %{model: "nova-2", interim_results: true}
      iex> {:ok, websocket} = Deepgram.Listen.WebSocket.start_link(client, options)
      {:ok, #PID<...>}

  """
  @spec start_link(Client.t(), Listen.live_options(), pid() | nil) ::
          {:ok, pid()} | {:error, any()}
  def start_link(%Client{} = client, options \\ %{}, callback_pid \\ nil) do
    url = build_websocket_url(client, options)
    headers = build_websocket_headers(client)
    callback_pid = callback_pid || self()

    initial_state = %{
      client: client,
      options: options,
      callback_pid: callback_pid,
      connected: false,
      keepalive_ref: nil
    }

    WebSockex.start_link(url, __MODULE__, initial_state, extra_headers: headers)
  end

  @doc """
  Sends audio data to the WebSocket.

  ## Parameters

  - `websocket` - The WebSocket process PID
  - `audio_data` - Binary audio data to send

  ## Examples

      iex> Deepgram.Listen.WebSocket.send_audio(websocket, audio_data)
      :ok

  """
  @spec send_audio(pid(), binary()) :: :ok
  def send_audio(websocket, audio_data) when is_binary(audio_data) do
    WebSockex.send_frame(websocket, {:binary, audio_data})
  end

  @doc """
  Sends a keepalive message to the WebSocket.

  ## Parameters

  - `websocket` - The WebSocket process PID

  ## Examples

      iex> Deepgram.Listen.WebSocket.send_keepalive(websocket)
      :ok

  """
  @spec send_keepalive(pid()) :: :ok
  def send_keepalive(websocket) do
    keepalive_message = Jason.encode!(%{type: "KeepAlive"})
    WebSockex.send_frame(websocket, {:text, keepalive_message})
  end

  @doc """
  Finishes the transcription session.

  ## Parameters

  - `websocket` - The WebSocket process PID

  ## Examples

      iex> Deepgram.Listen.WebSocket.finish(websocket)
      :ok

  """
  @spec finish(pid()) :: :ok
  def finish(websocket) do
    finish_message = Jason.encode!(%{type: "CloseStream"})
    WebSockex.send_frame(websocket, {:text, finish_message})
  end

  @doc """
  Closes the WebSocket connection.

  ## Parameters

  - `websocket` - The WebSocket process PID

  ## Examples

      iex> Deepgram.Listen.WebSocket.close(websocket)
      :ok

  """
  @spec close(pid()) :: :ok
  def close(websocket) do
    GenServer.stop(websocket)
  end

  # WebSockex callbacks

  @impl WebSockex
  def handle_connect(_conn, state) do
    Logger.info("Connected to Deepgram Live Transcription")

    # Start keepalive timer
    keepalive_ref = Process.send_after(self(), :keepalive, @keepalive_interval)

    new_state = %{state | connected: true, keepalive_ref: keepalive_ref}

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
  def handle_frame({:binary, _data}, state) do
    # Handle binary frames if needed
    {:ok, state}
  end

  @impl WebSockex
  def handle_frame(frame, state) do
    Logger.debug("Received unhandled frame: #{inspect(frame)}")
    {:ok, state}
  end

  @impl WebSockex
  def handle_info(:keepalive, state) do
    if state.connected do
      send_keepalive(self())
      keepalive_ref = Process.send_after(self(), :keepalive, @keepalive_interval)
      {:ok, %{state | keepalive_ref: keepalive_ref}}
    else
      {:ok, state}
    end
  end

  @impl WebSockex
  def handle_info(_info, state) do
    {:ok, state}
  end

  @impl WebSockex
  def handle_disconnect(%{reason: reason}, state) do
    Logger.info("Disconnected from Deepgram Live Transcription: #{inspect(reason)}")

    # Cancel keepalive timer
    if state.keepalive_ref do
      Process.cancel_timer(state.keepalive_ref)
    end

    new_state = %{state | connected: false, keepalive_ref: nil}

    # Notify callback process
    send(state.callback_pid, {:deepgram_disconnected, reason})

    {:ok, new_state}
  end

  @impl WebSockex
  def terminate(reason, state) do
    Logger.info("WebSocket terminated: #{inspect(reason)}")

    # Cancel keepalive timer
    if state.keepalive_ref do
      Process.cancel_timer(state.keepalive_ref)
    end

    # Notify callback process
    send(state.callback_pid, {:deepgram_terminated, reason})

    :ok
  end

  # Private helper functions

  defp handle_message(%{"type" => "Results"} = message, state) do
    send(state.callback_pid, {:deepgram_result, message})
    {:ok, state}
  end

  defp handle_message(%{"type" => "Metadata"} = message, state) do
    send(state.callback_pid, {:deepgram_metadata, message})
    {:ok, state}
  end

  defp handle_message(%{"type" => "SpeechStarted"} = message, state) do
    send(state.callback_pid, {:deepgram_speech_started, message})
    {:ok, state}
  end

  defp handle_message(%{"type" => "UtteranceEnd"} = message, state) do
    send(state.callback_pid, {:deepgram_utterance_end, message})
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
  Builds the WebSocket URL for live transcription.
  """
  def build_websocket_url(%Client{config: config}, options) do
    base_url = String.replace(config.base_url, ~r/^https?/, "wss")
    query_params = build_query_params(options)

    case query_params do
      [] -> "#{base_url}/#{@api_version}/listen"
      params -> "#{base_url}/#{@api_version}/listen?#{URI.encode_query(params)}"
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
