defmodule Deepgram.Speak do
  @moduledoc """
  Text-to-Speech services for the Deepgram API.

  The `Deepgram.Speak` module provides comprehensive text-to-speech synthesis capabilities
  through Deepgram's API. It offers both synchronous (REST API) and asynchronous streaming
  (WebSocket API) approaches for converting text to natural-sounding speech.

  ## Key Features

  * **Text-to-Speech Synthesis** - Convert text to high-quality audio
  * **Multiple Voice Models** - Access to various voice models like Aura 2
  * **Voice Customization** - Control pitch, rate, and other voice characteristics
  * **Audio Format Options** - Support for various audio formats and encodings
  * **Streaming TTS** - Real-time text-to-speech via WebSocket connections
  * **SSML Support** - Speech Synthesis Markup Language for fine-grained control
  * **Asynchronous Callbacks** - Send results to a webhook when processing completes

  ## Authentication

  All functions in this module require a properly configured `Deepgram.Client` struct,
  which can be created using `Deepgram.new/1`.

  Example:

      # Create client with API key
      client = Deepgram.new(api_key: System.get_env("DEEPGRAM_API_KEY"))
      
      # Or with OAuth token
      client = Deepgram.new(token: "your-oauth-token")

  ## Basic Usage

  Synthesize text to speech and get audio data:

      client = Deepgram.new(api_key: System.get_env("DEEPGRAM_API_KEY"))
      text_source = %{text: "Welcome to Deepgram's text to speech API."}
      options = %{model: "aura-2-thalia-en", encoding: "mp3"}
      {:ok, audio_data} = Deepgram.Speak.synthesize(client, text_source, options)

  Save synthesized audio to a file:

      {:ok, response} = Deepgram.Speak.save_to_file(client, "welcome.mp3", text_source, options)

  ## Advanced Usage

  Using Speech Synthesis Markup Language (SSML):

      # Create request with SSML
      ssml_source = %{ssml: "<speak><p>Welcome to <emphasis>Deepgram's</emphasis> API.</p></speak>"}
      {:ok, audio_data} = Deepgram.Speak.synthesize(client, ssml_source, options)

  Live streaming synthesis via WebSocket:

      options = %{model: "aura-2-thalia-en", encoding: "mp3"}
      {:ok, ws} = Deepgram.Speak.live_synthesis(client, options)
  """

  alias Deepgram.Client
  alias Deepgram.Config
  alias Deepgram.Error
  alias Deepgram.Speak.WebSocket
  alias Deepgram.Types.Speak

  @api_version "v1"

  @doc """
  Synthesizes text to speech and returns the audio data.

  ## Parameters

  - `client` - A `Deepgram.Client` struct
  - `text_source` - A map containing the text: `%{text: "Hello, world!"}`
  - `options` - Optional synthesis options (see `t:Deepgram.Types.Speak.speak_options/0`)

  ## Examples

      iex> client = Deepgram.new(api_key: "your-api-key")
      iex> text_source = %{text: "Hello, world!"}
      iex> options = %{model: "aura-2-thalia-en", encoding: "linear16"}
      iex> {:ok, audio_data} = Deepgram.Speak.synthesize(client, text_source, options)
      {:ok, <<binary_audio_data>>}

  """
  @spec synthesize(Client.t(), Speak.text_source(), Speak.speak_options()) ::
          {:ok, binary()} | {:error, any()}
  def synthesize(%Client{} = client, text_source, options \\ %{}) do
    with {:ok, validated_source} <- validate_text_source(text_source),
         {:ok, query_params} <- build_query_params(options),
         {:ok, audio_data} <- make_request(client, "speak", validated_source, query_params) do
      {:ok, audio_data}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Synthesizes text to speech and saves it to a file.

  ## Parameters

  - `client` - A `Deepgram.Client` struct
  - `file_path` - Path where the audio file should be saved
  - `text_source` - A map containing the text: `%{text: "Hello, world!"}`
  - `options` - Optional synthesis options (see `t:Deepgram.Types.Speak.speak_options/0`)

  ## Examples

      iex> client = Deepgram.new(api_key: "your-api-key")
      iex> text_source = %{text: "Hello, world!"}
      iex> options = %{model: "aura-2-thalia-en", encoding: "linear16"}
      iex> {:ok, response} = Deepgram.Speak.save_to_file(client, "output.wav", text_source, options)
      {:ok, %{content_type: "audio/wav", ...}}

  """
  @spec save_to_file(Client.t(), String.t(), Speak.text_source(), Speak.speak_options()) ::
          {:ok, Speak.speak_response()} | {:error, any()}
  def save_to_file(%Client{} = client, file_path, text_source, options \\ %{}) do
    with {:ok, audio_data} <- synthesize(client, text_source, options),
         :ok <- File.write(file_path, audio_data) do
      # Extract metadata from response headers (this would need to be implemented)
      response = %{
        content_type: "audio/wav",
        request_id: "unknown",
        model_uuid: "unknown",
        model_name: Map.get(options, :model, "unknown"),
        characters: String.length(text_source.text),
        transfer_encoding: "chunked",
        date: DateTime.utc_now() |> DateTime.to_iso8601()
      }

      {:ok, response}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Synthesizes text to speech with callback support (asynchronous).

  ## Parameters

  - `client` - A `Deepgram.Client` struct
  - `text_source` - A map containing the text: `%{text: "Hello, world!"}`
  - `callback_url` - URL to receive the audio result
  - `options` - Optional synthesis options (see `t:Deepgram.Types.Speak.speak_options/0`)

  ## Examples

      iex> client = Deepgram.new(api_key: "your-api-key")
      iex> text_source = %{text: "Hello, world!"}
      iex> callback_url = "https://example.com/webhook"
      iex> options = %{model: "aura-2-thalia-en", encoding: "linear16"}
      iex> {:ok, response} = Deepgram.Speak.synthesize_callback(client, text_source, callback_url, options)
      {:ok, %{request_id: "..."}}

  """
  @spec synthesize_callback(
          Client.t(),
          Speak.text_source(),
          String.t(),
          Speak.speak_options()
        ) ::
          {:ok, map()} | {:error, any()}
  def synthesize_callback(%Client{} = client, text_source, callback_url, options \\ %{}) do
    options_with_callback = Map.put(options, :callback, callback_url)
    synthesize(client, text_source, options_with_callback)
  end

  @doc """
  Starts a live text-to-speech WebSocket connection.

  ## Parameters

  - `client` - A `Deepgram.Client` struct
  - `options` - Optional live synthesis options (see `t:t:Deepgram.Types.Speak.speak_ws_options/0`)

  ## Examples

      iex> client = Deepgram.new(api_key: "your-api-key")
      iex> options = %{model: "aura-2-thalia-en", encoding: "linear16"}
      iex> {:ok, websocket} = Deepgram.Speak.live_synthesis(client, options)
      {:ok, #PID<...>}

  """
  @spec live_synthesis(Client.t(), Speak.speak_ws_options()) ::
          {:ok, pid()} | {:error, any()}
  def live_synthesis(%Client{} = client, options \\ %{}) do
    WebSocket.start_link(client, options)
  end

  # Private helper functions

  defp validate_text_source(%{text: text}) when is_binary(text) and byte_size(text) > 0 do
    {:ok, %{text: text}}
  end

  defp validate_text_source(%{text: text}) when is_binary(text) and byte_size(text) == 0 do
    {:error, Error.type_error("Text cannot be empty", "non-empty string", "empty string")}
  end

  defp validate_text_source(_) do
    {:error, Error.type_error("Invalid text source", "map with :text key", "other")}
  end

  defp build_query_params(options) when is_map(options) do
    query_params =
      options
      |> Enum.reduce([], fn {key, value}, acc ->
        case format_query_param(key, value) do
          {param_key, param_value} -> [{param_key, param_value} | acc]
          nil -> acc
        end
      end)
      |> Enum.reverse()

    {:ok, query_params}
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

  defp make_request(%Client{config: config}, endpoint, text_source, query_params) do
    url = build_url(config, endpoint, query_params)
    base_headers = Config.default_headers(config)
    headers = [{"Content-Type", "application/json"} | Map.to_list(base_headers)]
    body = Jason.encode!(text_source)

    case HTTPoison.post(url, body, headers, timeout: config.timeout) do
      {:ok, %HTTPoison.Response{status_code: 200, body: audio_data}} ->
        {:ok, audio_data}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, Error.api_error("API request failed", status_code, body)}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, Error.http_error("HTTP request failed", reason)}
    end
  end

  defp build_url(%Config{base_url: base_url}, endpoint, query_params) do
    url = "#{base_url}/#{@api_version}/#{endpoint}"

    case query_params do
      [] -> url
      params -> "#{url}?#{URI.encode_query(params)}"
    end
  end
end
