defmodule Deepgram.Types.Listen do
  @moduledoc """
  Types for the Listen (Speech-to-Text) service.
  """

  @type source :: %{
          url: String.t()
        }

  @type file_source :: %{
          file: binary()
        }

  @type stream_source :: %{
          stream: any()
        }

  @type prerecorded_options :: %{
          optional(:alternatives) => integer(),
          optional(:channels) => integer(),
          optional(:callback) => String.t(),
          optional(:callback_method) => String.t(),
          optional(:custom_intent) => [String.t()] | String.t(),
          optional(:custom_intent_mode) => String.t(),
          optional(:custom_topic) => [String.t()] | String.t(),
          optional(:custom_topic_mode) => String.t(),
          optional(:detect_entities) => boolean(),
          optional(:detect_language) => boolean(),
          optional(:detect_topics) => boolean(),
          optional(:diarize) => boolean(),
          optional(:diarize_version) => String.t(),
          optional(:dictation) => boolean(),
          optional(:encoding) => String.t(),
          optional(:extra) => [String.t()] | String.t(),
          optional(:filler_words) => boolean(),
          optional(:intents) => boolean(),
          optional(:keyterm) => [String.t()],
          optional(:keywords) => [String.t()] | String.t(),
          optional(:language) => String.t(),
          optional(:measurements) => boolean(),
          optional(:model) => String.t(),
          optional(:multichannel) => boolean(),
          optional(:numerals) => boolean(),
          optional(:paragraphs) => boolean(),
          optional(:profanity_filter) => boolean(),
          optional(:punctuate) => boolean(),
          optional(:redact) => [String.t()] | boolean() | String.t(),
          optional(:replace) => [String.t()] | String.t(),
          optional(:sample_rate) => integer(),
          optional(:search) => [String.t()] | String.t(),
          optional(:sentiment) => boolean(),
          optional(:smart_format) => boolean(),
          optional(:summarize) => boolean() | String.t(),
          optional(:tag) => [String.t()],
          optional(:tier) => String.t(),
          optional(:topics) => boolean(),
          optional(:utt_split) => float(),
          optional(:utterances) => boolean(),
          optional(:version) => String.t()
        }

  @type live_options :: %{
          optional(:channels) => integer(),
          optional(:encoding) => String.t(),
          optional(:endpointing) => boolean(),
          optional(:filler_words) => boolean(),
          optional(:interim_results) => boolean(),
          optional(:keywords) => [String.t()] | String.t(),
          optional(:language) => String.t(),
          optional(:model) => String.t(),
          optional(:multichannel) => boolean(),
          optional(:numerals) => boolean(),
          optional(:profanity_filter) => boolean(),
          optional(:punctuate) => boolean(),
          optional(:redact) => [String.t()] | boolean() | String.t(),
          optional(:replace) => [String.t()] | String.t(),
          optional(:sample_rate) => integer(),
          optional(:search) => [String.t()] | String.t(),
          optional(:smart_format) => boolean(),
          optional(:tag) => [String.t()],
          optional(:tier) => String.t(),
          optional(:utterances) => boolean(),
          optional(:version) => String.t(),
          optional(:vad_events) => boolean()
        }

  @type word :: %{
          word: String.t(),
          start: float(),
          end: float(),
          confidence: float(),
          punctuated_word: String.t()
        }

  @type alternative :: %{
          transcript: String.t(),
          confidence: float(),
          words: [word()]
        }

  @type channel :: %{
          alternatives: [alternative()]
        }

  @type metadata :: %{
          transaction_key: String.t(),
          request_id: String.t(),
          sha256: String.t(),
          created: String.t(),
          duration: float(),
          channels: integer(),
          models: [String.t()],
          model_info: map()
        }

  @type results :: %{
          channels: [channel()],
          utterances: [map()] | nil,
          summary: map() | nil,
          intents: map() | nil,
          sentiments: map() | nil,
          topics: map() | nil,
          entities: [map()] | nil
        }

  @type transcription_response :: %{
          metadata: metadata(),
          results: results()
        }

  @type async_response :: %{
          request_id: String.t()
        }

  @type live_result :: %{
          type: String.t(),
          channel_index: [integer()],
          duration: float(),
          start: float(),
          is_final: boolean(),
          speech_final: boolean(),
          channel: channel()
        }

  @type live_metadata :: %{
          transaction_key: String.t(),
          request_id: String.t(),
          sha256: String.t(),
          created: String.t(),
          duration: float(),
          channels: integer(),
          models: [String.t()]
        }

  @type live_response :: %{
          type: String.t(),
          channel_index: [integer()],
          duration: float(),
          start: float(),
          is_final: boolean(),
          speech_final: boolean(),
          channel: channel()
        }

  @type speech_started :: %{
          type: String.t(),
          channel_index: [integer()],
          timestamp: String.t()
        }

  @type utterance_end :: %{
          type: String.t(),
          channel_index: [integer()],
          last_word_end: float()
        }

  @type error_response :: %{
          type: String.t(),
          description: String.t(),
          message: String.t(),
          variant: String.t()
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
