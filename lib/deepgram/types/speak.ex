defmodule Deepgram.Types.Speak do
  @moduledoc """
  Types for the Speak (Text-to-Speech) service.
  """

  @type text_source :: %{
          text: String.t()
        }

  @type speak_options :: %{
          optional(:model) => String.t(),
          optional(:encoding) => String.t(),
          optional(:container) => String.t(),
          optional(:sample_rate) => integer(),
          optional(:bit_rate) => integer(),
          optional(:callback) => String.t(),
          optional(:callback_method) => String.t()
        }

  @type speak_ws_options :: %{
          optional(:model) => String.t(),
          optional(:encoding) => String.t(),
          optional(:container) => String.t(),
          optional(:sample_rate) => integer(),
          optional(:bit_rate) => integer()
        }

  @type speak_response :: %{
          content_type: String.t(),
          request_id: String.t(),
          model_uuid: String.t(),
          model_name: String.t(),
          characters: integer(),
          transfer_encoding: String.t(),
          date: String.t()
        }

  @type speak_ws_metadata :: %{
          type: String.t(),
          request_id: String.t(),
          model_uuid: String.t(),
          model_name: String.t(),
          characters: integer(),
          transfer_encoding: String.t(),
          date: String.t()
        }

  @type audio_data :: %{
          type: String.t(),
          data: binary()
        }

  @type flushed_response :: %{
          type: String.t()
        }

  @type cleared_response :: %{
          type: String.t()
        }

  @type warning_response :: %{
          type: String.t(),
          warn_code: String.t(),
          warn_msg: String.t()
        }

  @type error_response :: %{
          type: String.t(),
          error_code: String.t(),
          error_msg: String.t()
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
