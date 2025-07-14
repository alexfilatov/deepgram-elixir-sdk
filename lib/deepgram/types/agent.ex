defmodule Deepgram.Types.Agent do
  @moduledoc """
  Types for the Agent (AI Voice Agent) service.
  """

  @type provider :: %{
          type: String.t(),
          model: String.t()
        }

  @type listen_config :: %{
          model: String.t(),
          language: String.t(),
          smart_format: boolean(),
          encoding: String.t(),
          channels: integer(),
          sample_rate: integer(),
          interim_results: boolean(),
          punctuate: boolean(),
          profanity_filter: boolean(),
          redact: [String.t()],
          endpointing: boolean(),
          utterance_end_ms: integer(),
          vad_turnoff: integer(),
          provider: provider()
        }

  @type speak_config :: %{
          model: String.t(),
          encoding: String.t(),
          container: String.t(),
          sample_rate: integer(),
          provider: provider()
        }

  @type think_config :: %{
          provider: provider(),
          model: String.t(),
          instructions: String.t(),
          knowledge: String.t()
        }

  @type agent_config :: %{
          listen: listen_config(),
          think: think_config(),
          speak: speak_config()
        }

  @type settings_options :: %{
          agent: agent_config(),
          version: String.t(),
          format: String.t(),
          encoding: String.t(),
          sample_rate: integer(),
          channels: integer(),
          language: String.t(),
          greeting: String.t()
        }

  @type function_def :: %{
          name: String.t(),
          description: String.t(),
          parameters: map(),
          required: [String.t()]
        }

  @type function_call_request :: %{
          type: String.t(),
          function_call: %{
            name: String.t(),
            arguments: String.t()
          }
        }

  @type function_call_response :: %{
          type: String.t(),
          function_call_id: String.t(),
          result: any()
        }

  @type inject_message_options :: %{
          type: String.t(),
          content: String.t(),
          role: String.t()
        }

  @type welcome_response :: %{
          type: String.t(),
          message: String.t()
        }

  @type settings_applied_response :: %{
          type: String.t(),
          settings: map()
        }

  @type conversation_text_response :: %{
          type: String.t(),
          text: String.t(),
          role: String.t()
        }

  @type user_started_speaking_response :: %{
          type: String.t(),
          timestamp: String.t()
        }

  @type agent_thinking_response :: %{
          type: String.t(),
          thinking: boolean()
        }

  @type agent_started_speaking_response :: %{
          type: String.t(),
          timestamp: String.t()
        }

  @type agent_audio_done_response :: %{
          type: String.t(),
          timestamp: String.t()
        }

  @type injection_refused_response :: %{
          type: String.t(),
          reason: String.t()
        }

  @type error_response :: %{
          type: String.t(),
          error: String.t(),
          message: String.t()
        }

  @type close_response :: %{
          type: String.t()
        }

  @type open_response :: %{
          type: String.t()
        }

  @type unhandled_response :: %{
          type: String.t(),
          raw: String.t()
        }
end
