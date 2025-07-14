defmodule Deepgram.Agent.WebSocket do
  @moduledoc """
  WebSocket client for AI voice agent interactions.

  This module provides a WebSocket client that can connect to Deepgram's
  AI voice agent service for real-time conversational AI interactions.
  """

  use WebSockex

  alias Deepgram.Client
  alias Deepgram.Config
  alias Deepgram.Error
  alias Deepgram.Types.Agent

  require Logger

  @type state :: %{
          client: Client.t(),
          settings: Agent.settings_options(),
          callback_pid: pid() | nil,
          connected: boolean(),
          keepalive_ref: reference() | nil
        }

  @keepalive_interval 30_000
  @api_version "v1"

  @doc """
  Starts a WebSocket connection for AI voice agent interactions.

  ## Parameters

  - `client` - A `Deepgram.Client` struct
  - `settings` - Agent configuration settings
  - `callback_pid` - Optional PID to receive messages (defaults to caller)

  ## Examples

      iex> client = Deepgram.new(api_key: "your-api-key")
      iex> settings = %{agent: %{...}, ...}
      iex> {:ok, agent} = Deepgram.Agent.WebSocket.start_link(client, settings)
      {:ok, #PID<...>}

  """
  @spec start_link(Client.t(), Agent.settings_options(), pid() | nil) ::
          {:ok, pid()} | {:error, any()}
  def start_link(%Client{} = client, settings, callback_pid \\ nil) do
    url = build_websocket_url(client)
    headers = build_websocket_headers(client)
    callback_pid = callback_pid || self()

    initial_state = %{
      client: client,
      settings: settings,
      callback_pid: callback_pid,
      connected: false,
      keepalive_ref: nil
    }

    WebSockex.start_link(url, __MODULE__, initial_state, extra_headers: headers)
  end

  @doc """
  Sends audio data to the agent.
  """
  @spec send_audio(pid(), binary()) :: :ok
  def send_audio(agent, audio_data) when is_binary(audio_data) do
    WebSockex.send_frame(agent, {:binary, audio_data})
  end

  @doc """
  Sends a text message to the agent.
  """
  @spec send_text(pid(), String.t()) :: :ok
  def send_text(agent, text) when is_binary(text) do
    message = Jason.encode!(%{type: "user_message", text: text})
    WebSockex.send_frame(agent, {:text, message})
  end

  @doc """
  Responds to a function call from the agent.
  """
  @spec respond_to_function_call(pid(), String.t(), any()) :: :ok
  def respond_to_function_call(agent, function_call_id, result) do
    message =
      Jason.encode!(%{
        type: "function_call_response",
        function_call_id: function_call_id,
        result: result
      })

    WebSockex.send_frame(agent, {:text, message})
  end

  @doc """
  Injects a message into the agent conversation.
  """
  @spec inject_message(pid(), Agent.inject_message_options()) :: :ok
  def inject_message(agent, message) do
    encoded_message = Jason.encode!(message)
    WebSockex.send_frame(agent, {:text, encoded_message})
  end

  @doc """
  Updates the agent's configuration.
  """
  @spec update_settings(pid(), Agent.settings_options()) :: :ok
  def update_settings(agent, settings) do
    message = Jason.encode!(%{type: "SettingsConfiguration", settings: settings})
    WebSockex.send_frame(agent, {:text, message})
  end

  @doc """
  Sends a keepalive message to maintain the connection.
  """
  @spec keepalive(pid()) :: :ok
  def keepalive(agent) do
    message = Jason.encode!(%{type: "KeepAlive"})
    WebSockex.send_frame(agent, {:text, message})
  end

  @doc """
  Closes the agent session.
  """
  @spec close(pid()) :: :ok
  def close(agent) do
    message = Jason.encode!(%{type: "Close"})
    WebSockex.send_frame(agent, {:text, message})
  end

  # WebSockex callbacks

  @impl WebSockex
  def handle_connect(_conn, state) do
    Logger.info("Connected to Deepgram AI Agent")

    # Send initial settings
    settings_message =
      Jason.encode!(%{
        type: "SettingsConfiguration",
        settings: state.settings
      })

    WebSockex.send_frame(self(), {:text, settings_message})

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
  def handle_frame({:binary, audio_data}, state) do
    # Handle binary audio data from agent
    send(state.callback_pid, {:deepgram_audio, audio_data})
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
      keepalive(self())
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
    Logger.info("Disconnected from Deepgram AI Agent: #{inspect(reason)}")

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
    Logger.info("Agent WebSocket terminated: #{inspect(reason)}")

    # Cancel keepalive timer
    if state.keepalive_ref do
      Process.cancel_timer(state.keepalive_ref)
    end

    # Notify callback process
    send(state.callback_pid, {:deepgram_terminated, reason})

    :ok
  end

  # Private helper functions

  defp handle_message(%{"type" => "Welcome"} = message, state) do
    send(state.callback_pid, {:deepgram_welcome, message})
    {:ok, state}
  end

  defp handle_message(%{"type" => "SettingsApplied"} = message, state) do
    send(state.callback_pid, {:deepgram_settings_applied, message})
    {:ok, state}
  end

  defp handle_message(%{"type" => "ConversationText"} = message, state) do
    send(state.callback_pid, {:deepgram_conversation_text, message})
    {:ok, state}
  end

  defp handle_message(%{"type" => "UserStartedSpeaking"} = message, state) do
    send(state.callback_pid, {:deepgram_user_started_speaking, message})
    {:ok, state}
  end

  defp handle_message(%{"type" => "AgentThinking"} = message, state) do
    send(state.callback_pid, {:deepgram_agent_thinking, message})
    {:ok, state}
  end

  defp handle_message(%{"type" => "AgentStartedSpeaking"} = message, state) do
    send(state.callback_pid, {:deepgram_agent_started_speaking, message})
    {:ok, state}
  end

  defp handle_message(%{"type" => "AgentAudioDone"} = message, state) do
    send(state.callback_pid, {:deepgram_agent_audio_done, message})
    {:ok, state}
  end

  defp handle_message(%{"type" => "FunctionCallRequest"} = message, state) do
    send(state.callback_pid, {:deepgram_function_call_request, message})
    {:ok, state}
  end

  defp handle_message(%{"type" => "InjectionRefused"} = message, state) do
    send(state.callback_pid, {:deepgram_injection_refused, message})
    {:ok, state}
  end

  defp handle_message(%{"type" => "Error"} = message, state) do
    error = Error.websocket_error("Agent WebSocket error", message)
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
  Builds the WebSocket URL for agent connection.
  """
  def build_websocket_url(%Client{config: config}) do
    base_url = String.replace(config.base_url, ~r/^https?/, "wss")
    "#{base_url}/#{@api_version}/agent"
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
end
