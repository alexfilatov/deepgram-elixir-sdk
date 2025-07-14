defmodule Deepgram.Agent do
  @moduledoc """
  AI Voice Agent services for the Deepgram API.

  The `Deepgram.Agent` module provides sophisticated conversational AI capabilities
  through Deepgram's AI Voice Agent API. It enables developers to create interactive
  voice and text-based agents using WebSocket connections for real-time communication.

  ## Key Features

  * **Conversational AI** - Create intelligent voice and text-based agents
  * **Real-time Interaction** - Maintain continuous WebSocket connections
  * **Speech-to-Text Integration** - Process spoken audio in real-time
  * **Text-to-Speech Response** - Generate natural-sounding voice responses
  * **Function Calling** - Trigger custom functions from agent conversations
  * **Session Management** - Maintain conversational context and state
  * **Multi-modal Input** - Accept both audio and text input
  * **Message Injection** - Add context or system messages to conversations
  * **Dynamic Configuration** - Update agent settings during active sessions

  ## Architecture

  The Agent module integrates three core components:

  1. **Listen** - Speech-to-Text processing (audio input → text)
  2. **Think** - Natural language understanding and reasoning
  3. **Speak** - Text-to-Speech synthesis (text → audio output)

  ## Authentication

  All functions in this module require a properly configured `Deepgram.Client` struct,
  which can be created using `Deepgram.new/1`.

  Example:

      # Create client with API key
      client = Deepgram.new(api_key: System.get_env("DEEPGRAM_API_KEY"))
      
      # Or with OAuth token
      client = Deepgram.new(token: "your-oauth-token")

  ## Basic Usage

  Start an agent session with configuration:

      client = Deepgram.new(api_key: System.get_env("DEEPGRAM_API_KEY"))
      
      # Configure agent settings
      settings = %{
        agent: %{
          listen: %{model: "nova-2", language: "en"},
          think: %{provider: %{type: "deepgram"}, instructions: "You are a helpful assistant."},
          speak: %{model: "aura-2-thalia-en", encoding: "linear16"}
        },
        greeting: "Hello! How can I help you today?"
      }
      
      # Start the agent session
      {:ok, agent} = Deepgram.Agent.start_session(client, settings)

  Send audio data to the agent:

      # Send audio chunks to the agent
      Deepgram.Agent.send_audio(agent, audio_chunk)

  Send text input to the agent:

      # Send text message
      Deepgram.Agent.send_text(agent, "What's the weather like today?")

  ## Advanced Usage

  Handle function calls from the agent:

      # Respond to a function call
      function_call_id = "abc123"
      result = %{temperature: 72, conditions: "sunny", location: "San Francisco"}
      Deepgram.Agent.respond_to_function_call(agent, function_call_id, result)

  Inject a message into the conversation:

      # Add system message
      system_message = %{
        type: "system_message",
        content: "The user is interested in technical information.",
        role: "system"
      }
      Deepgram.Agent.inject_message(agent, system_message)

  Update agent configuration during a session:

      # Change agent behavior
      new_settings = %{
        agent: %{
          think: %{instructions: "You are now a cooking expert assistant."}
        }
      }
      Deepgram.Agent.update_settings(agent, new_settings)
  """

  alias Deepgram.Agent.WebSocket
  alias Deepgram.Client
  alias Deepgram.Types.Agent

  @doc """
  Starts an AI voice agent WebSocket connection.

  ## Parameters

  - `client` - A `Deepgram.Client` struct
  - `settings` - Agent configuration settings (see `t:Deepgram.Types.Agent.settings_options/0`)

  ## Examples

      iex> client = Deepgram.new(api_key: "your-api-key")
      iex> settings = %{
      ...>   agent: %{
      ...>     listen: %{
      ...>       model: "nova-2",
      ...>       language: "en",
      ...>       smart_format: true,
      ...>       encoding: "linear16",
      ...>       sample_rate: 16000,
      ...>       channels: 1,
      ...>       interim_results: true,
      ...>       punctuate: true,
      ...>       profanity_filter: true,
      ...>       redact: ["pci", "ssn"],
      ...>       endpointing: true,
      ...>       utterance_end_ms: 1000,
      ...>       vad_turnoff: 1000,
      ...>       provider: %{
      ...>         type: "deepgram",
      ...>         model: "nova-2"
      ...>       }
      ...>     },
      ...>     think: %{
      ...>       provider: %{
      ...>         type: "open_ai",
      ...>         model: "gpt-4"
      ...>       },
      ...>       instructions: "You are a helpful assistant.",
      ...>       knowledge: ""
      ...>     },
      ...>     speak: %{
      ...>       model: "aura-2-thalia-en",
      ...>       encoding: "linear16",
      ...>       container: "none",
      ...>       sample_rate: 16000,
      ...>       provider: %{
      ...>         type: "deepgram",
      ...>         model: "aura-2-thalia-en"
      ...>       }
      ...>     }
      ...>   },
      ...>   version: "latest",
      ...>   format: "text",
      ...>   encoding: "linear16",
      ...>   sample_rate: 16000,
      ...>   channels: 1,
      ...>   language: "en",
      ...>   greeting: "Hello! How can I help you today?"
      ...> }
      iex> {:ok, agent} = Deepgram.Agent.start_session(client, settings)
      {:ok, #PID<...>}

  """
  @spec start_session(Client.t(), Agent.settings_options()) ::
          {:ok, pid()} | {:error, any()}
  def start_session(%Client{} = client, settings) do
    WebSocket.start_link(client, settings)
  end

  @doc """
  Sends audio data to the agent.

  ## Parameters

  - `agent` - The agent WebSocket process PID
  - `audio_data` - Binary audio data to send

  ## Examples

      iex> Deepgram.Agent.send_audio(agent, audio_data)
      :ok

  """
  @spec send_audio(pid(), binary()) :: :ok
  def send_audio(agent, audio_data) when is_binary(audio_data) do
    WebSocket.send_audio(agent, audio_data)
  end

  @doc """
  Sends a text message to the agent.

  ## Parameters

  - `agent` - The agent WebSocket process PID
  - `text` - Text message to send

  ## Examples

      iex> Deepgram.Agent.send_text(agent, "Hello, how are you?")
      :ok

  """
  @spec send_text(pid(), String.t()) :: :ok
  def send_text(agent, text) when is_binary(text) do
    WebSocket.send_text(agent, text)
  end

  @doc """
  Responds to a function call from the agent.

  ## Parameters

  - `agent` - The agent WebSocket process PID
  - `function_call_id` - ID of the function call to respond to
  - `result` - Result of the function call

  ## Examples

      iex> Deepgram.Agent.respond_to_function_call(agent, "call_123", %{status: "success"})
      :ok

  """
  @spec respond_to_function_call(pid(), String.t(), any()) :: :ok
  def respond_to_function_call(agent, function_call_id, result) do
    WebSocket.respond_to_function_call(agent, function_call_id, result)
  end

  @doc """
  Injects a message into the agent conversation.

  ## Parameters

  - `agent` - The agent WebSocket process PID
  - `message` - Message to inject (see `t:Deepgram.Types.Agent.inject_message_options/0`)

  ## Examples

      iex> message = %{
      ...>   type: "user_message",
      ...>   content: "What's the weather like?",
      ...>   role: "user"
      ...> }
      iex> Deepgram.Agent.inject_message(agent, message)
      :ok

  """
  @spec inject_message(pid(), Agent.inject_message_options()) :: :ok
  def inject_message(agent, message) do
    WebSocket.inject_message(agent, message)
  end

  @doc """
  Updates the agent's configuration.

  ## Parameters

  - `agent` - The agent WebSocket process PID
  - `settings` - New settings to apply

  ## Examples

      iex> new_settings = %{
      ...>   agent: %{
      ...>     think: %{
      ...>       instructions: "You are now a cooking assistant."
      ...>     }
      ...>   }
      ...> }
      iex> Deepgram.Agent.update_settings(agent, new_settings)
      :ok

  """
  @spec update_settings(pid(), Agent.settings_options()) :: :ok
  def update_settings(agent, settings) do
    WebSocket.update_settings(agent, settings)
  end

  @doc """
  Closes the agent session.

  ## Parameters

  - `agent` - The agent WebSocket process PID

  ## Examples

      iex> Deepgram.Agent.close_session(agent)
      :ok

  """
  @spec close_session(pid()) :: :ok
  def close_session(agent) do
    WebSocket.close(agent)
  end

  @doc """
  Sends a keepalive message to maintain the connection.

  ## Parameters

  - `agent` - The agent WebSocket process PID

  ## Examples

      iex> Deepgram.Agent.keepalive(agent)
      :ok

  """
  @spec keepalive(pid()) :: :ok
  def keepalive(agent) do
    WebSocket.keepalive(agent)
  end
end
