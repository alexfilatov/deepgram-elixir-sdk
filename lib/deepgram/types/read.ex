defmodule Deepgram.Types.Read do
  @moduledoc """
  Types for the Read (Text Intelligence) service.
  """

  @type text_source :: %{
          text: String.t()
        }

  @type analyze_options :: %{
          optional(:model) => String.t(),
          optional(:language) => String.t(),
          optional(:topics) => boolean(),
          optional(:intents) => boolean(),
          optional(:sentiment) => boolean(),
          optional(:summarize) => boolean() | String.t(),
          optional(:custom_intent) => [String.t()] | String.t(),
          optional(:custom_intent_mode) => String.t(),
          optional(:custom_topic) => [String.t()] | String.t(),
          optional(:custom_topic_mode) => String.t()
        }

  @type intent :: %{
          intent: String.t(),
          confidence_score: float()
        }

  @type intents_info :: %{
          model_uuid: String.t(),
          input_tokens: integer(),
          output_tokens: integer()
        }

  @type intents :: %{
          segments: [
            %{
              text: String.t(),
              start_word: integer(),
              end_word: integer(),
              intents: [intent()]
            }
          ],
          average: %{
            intent: String.t(),
            confidence_score: float()
          },
          info: intents_info()
        }

  @type sentiment :: %{
          sentiment: String.t(),
          confidence_score: float()
        }

  @type sentiment_info :: %{
          model_uuid: String.t(),
          input_tokens: integer(),
          output_tokens: integer()
        }

  @type sentiments :: %{
          segments: [
            %{
              text: String.t(),
              start_word: integer(),
              end_word: integer(),
              sentiments: [sentiment()]
            }
          ],
          average: %{
            sentiment: String.t(),
            confidence_score: float()
          },
          info: sentiment_info()
        }

  @type topic :: %{
          topic: String.t(),
          confidence_score: float()
        }

  @type topics_info :: %{
          model_uuid: String.t(),
          input_tokens: integer(),
          output_tokens: integer()
        }

  @type topics :: %{
          segments: [
            %{
              text: String.t(),
              start_word: integer(),
              end_word: integer(),
              topics: [topic()]
            }
          ],
          average: %{
            topics: [topic()]
          },
          info: topics_info()
        }

  @type summary_info :: %{
          model_uuid: String.t(),
          input_tokens: integer(),
          output_tokens: integer()
        }

  @type summary :: %{
          summary: String.t(),
          short_summary: String.t(),
          info: summary_info()
        }

  @type metadata :: %{
          request_id: String.t(),
          created: String.t(),
          language: String.t(),
          model_uuid: String.t(),
          input_tokens: integer(),
          output_tokens: integer()
        }

  @type results :: %{
          intents: intents() | nil,
          sentiments: sentiments() | nil,
          topics: topics() | nil,
          summary: summary() | nil
        }

  @type analyze_response :: %{
          metadata: metadata(),
          results: results()
        }
end
