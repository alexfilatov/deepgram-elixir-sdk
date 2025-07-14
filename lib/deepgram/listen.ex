defmodule Deepgram.Listen do
  @moduledoc """
  Speech-to-Text services for the Deepgram API.

  This module provides both prerecorded (REST API) and live (WebSocket API)
  speech-to-text transcription services. With Deepgram's Speech-to-Text capabilities,
  you can transcribe audio from various sources with high accuracy and customize the
  transcription process with a wide range of options.

  ## Key Features

  * **Multiple Input Sources**: Transcribe audio from URLs or files
  * **Real-time Streaming**: Transcribe live audio streams using WebSockets
  * **Asynchronous Processing**: Process large files with callback support
  * **Advanced Features**: Speaker diarization, punctuation, smart formatting
  * **Language Detection**: Automatic language identification
  * **Custom Models**: Use domain-specific models for higher accuracy

  ## Usage Examples

  ### Basic URL Transcription

  ```elixir
  client = Deepgram.new(api_key: "your-api-key")
  {:ok, response} = Deepgram.Listen.transcribe_url(client, %{url: "https://example.com/audio.wav"})
  ```

  ### Enhanced Transcription with Options

  ```elixir
  client = Deepgram.new(api_key: "your-api-key")
  {:ok, response} = Deepgram.Listen.transcribe_url(
    client, 
    %{url: "https://example.com/audio.wav"}, 
    %{
      model: "nova-2",         # Use the Nova-2 model
      punctuate: true,        # Add punctuation
      diarize: true,          # Identify different speakers
      smart_format: true,     # Format numbers, dates, etc.
      detect_language: true,  # Detect the audio language
      utterances: true        # Split by speaker turns
    }
  )
  ```

  ### Live Audio Streaming

  ```elixir
  # Start a WebSocket connection
  {:ok, websocket} = Deepgram.Listen.live_transcription(
    client,
    %{
      model: "nova-2",
      interim_results: true,  # Get results as they become available
      punctuate: true,
      encoding: "linear16",   # Audio encoding format
      sample_rate: 16000      # Audio sample rate in Hz
    }
  )

  # Send audio chunks
  Deepgram.Listen.WebSocket.send_audio(websocket, audio_chunk)

  # Handle incoming messages
  receive do
    {:deepgram_result, result} -> 
      # Process transcription result
    {:deepgram_error, error} -> 
      # Handle error
  end
  ```

  See the [examples directory](https://github.com/deepgram/deepgram-elixir-sdk/tree/main/examples) for more detailed usage examples.
  """

  alias Deepgram.Client
  alias Deepgram.Config
  alias Deepgram.Error
  alias Deepgram.Listen.WebSocket
  alias Deepgram.Types.Listen

  @api_version "v1"

  @doc """
  Transcribes audio from a URL source.

  ## Parameters

  - `client` - A `Deepgram.Client` struct
  - `source` - A map containing the URL: `%{url: "https://example.com/audio.wav"}`
  - `options` - Optional transcription options (see `t:Deepgram.Types.Listen.prerecorded_options/0`)

  ## Examples

      iex> client = Deepgram.new(api_key: "your-api-key")
      iex> source = %{url: "https://example.com/audio.wav"}
      iex> options = %{model: "nova-2", punctuate: true}
      iex> {:ok, response} = Deepgram.Listen.transcribe_url(client, source, options)
      {:ok, %{metadata: %{...}, results: %{...}}}

  """
  @spec transcribe_url(Client.t(), Listen.source(), Listen.prerecorded_options()) ::
          {:ok, Listen.transcription_response()} | {:error, any()}
  def transcribe_url(%Client{} = client, source, options \\ %{}) do
    with {:ok, validated_source} <- validate_url_source(source),
         {:ok, query_params} <- build_query_params(options),
         {:ok, response} <- make_request(client, "listen", validated_source, query_params) do
      {:ok, response}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Transcribes audio from a file.

  ## Parameters

  - `client` - A `Deepgram.Client` struct
  - `file_data` - Binary data of the audio file
  - `options` - Optional transcription options (see `t:Deepgram.Types.Listen.prerecorded_options/0`)

  ## Examples

      iex> client = Deepgram.new(api_key: "your-api-key")
      iex> {:ok, file_data} = File.read("path/to/audio.wav")
      iex> options = %{model: "nova-2", punctuate: true}
      iex> {:ok, response} = Deepgram.Listen.transcribe_file(client, file_data, options)
      {:ok, %{metadata: %{...}, results: %{...}}}

  """
  @spec transcribe_file(Client.t(), binary(), Listen.prerecorded_options()) ::
          {:ok, Listen.transcription_response()} | {:error, any()}
  def transcribe_file(%Client{} = client, file_data, options \\ %{}) when is_binary(file_data) do
    with {:ok, query_params} <- build_query_params(options),
         {:ok, response} <- make_file_request(client, "listen", file_data, query_params) do
      {:ok, response}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Transcribes audio from a URL with callback support (asynchronous).

  ## Parameters

  - `client` - A `Deepgram.Client` struct
  - `source` - A map containing the URL: `%{url: "https://example.com/audio.wav"}`
  - `callback_url` - URL to receive the transcription result
  - `options` - Optional transcription options (see `t:Deepgram.Types.Listen.prerecorded_options/0`)

  ## Examples

      iex> client = Deepgram.new(api_key: "your-api-key")
      iex> source = %{url: "https://example.com/audio.wav"}
      iex> callback_url = "https://example.com/webhook"
      iex> options = %{model: "nova-2", punctuate: true}
      iex> {:ok, response} = Deepgram.Listen.transcribe_url_callback(client, source, callback_url, options)
      {:ok, %{request_id: "..."}}

  """
  @spec transcribe_url_callback(
          Client.t(),
          Listen.source(),
          String.t(),
          Listen.prerecorded_options()
        ) ::
          {:ok, Listen.async_response()} | {:error, any()}
  def transcribe_url_callback(%Client{} = client, source, callback_url, options \\ %{}) do
    options_with_callback = Map.put(options, :callback, callback_url)
    transcribe_url(client, source, options_with_callback)
  end

  @doc """
  Transcribes audio from a file with callback support (asynchronous).

  ## Parameters

  - `client` - A `Deepgram.Client` struct
  - `file_data` - Binary data of the audio file
  - `callback_url` - URL to receive the transcription result
  - `options` - Optional transcription options (see `t:Deepgram.Types.Listen.prerecorded_options/0`)

  ## Examples

      iex> client = Deepgram.new(api_key: "your-api-key")
      iex> {:ok, file_data} = File.read("path/to/audio.wav")
      iex> callback_url = "https://example.com/webhook"
      iex> options = %{model: "nova-2", punctuate: true}
      iex> {:ok, response} = Deepgram.Listen.transcribe_file_callback(client, file_data, callback_url, options)
      {:ok, %{request_id: "..."}}

  """
  @spec transcribe_file_callback(
          Client.t(),
          binary(),
          String.t(),
          Listen.prerecorded_options()
        ) ::
          {:ok, Listen.async_response()} | {:error, any()}
  def transcribe_file_callback(%Client{} = client, file_data, callback_url, options \\ %{}) do
    options_with_callback = Map.put(options, :callback, callback_url)
    transcribe_file(client, file_data, options_with_callback)
  end

  @doc """
  Starts a live transcription WebSocket connection.

  ## Parameters

  - `client` - A `Deepgram.Client` struct
  - `options` - Optional live transcription options (similar to `t:t:Deepgram.Types.Listen.prerecorded_options/0`)

  ## Examples

      iex> client = Deepgram.new(api_key: "your-api-key")
      iex> options = %{model: "nova-2", interim_results: true}
      iex> {:ok, websocket} = Deepgram.Listen.live_transcription(client, options)
      {:ok, #PID<...>}

  """
  @spec live_transcription(Client.t(), Listen.live_options()) ::
          {:ok, pid()} | {:error, any()}
  def live_transcription(%Client{} = client, options \\ %{}) do
    WebSocket.start_link(client, options)
  end

  # Private helper functions

  defp validate_url_source(%{url: url}) when is_binary(url) do
    case URI.parse(url) do
      %URI{scheme: scheme} when scheme in ["http", "https"] ->
        {:ok, %{url: url}}

      _ ->
        {:error, Error.type_error("Invalid URL format", "valid HTTP/HTTPS URL", url)}
    end
  end

  defp validate_url_source(_) do
    {:error, Error.type_error("Invalid source", "map with :url key", "other")}
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

  defp make_request(%Client{config: config}, endpoint, source, query_params) do
    url = build_url(config, endpoint, query_params)
    base_headers = Config.default_headers(config)
    headers = [{"Content-Type", "application/json"} | Map.to_list(base_headers)]
    body = Jason.encode!(source)

    case HTTPoison.post(url, body, headers, timeout: config.timeout) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        case Jason.decode(response_body) do
          {:ok, parsed_response} -> {:ok, parsed_response}
          {:error, reason} -> {:error, Error.json_error("Failed to parse response", reason)}
        end

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, Error.api_error("API request failed", status_code, body)}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, Error.http_error("HTTP request failed", reason)}
    end
  end

  defp make_file_request(%Client{config: config}, endpoint, file_data, query_params) do
    url = build_url(config, endpoint, query_params)
    headers = Config.default_headers(config) |> Map.put("Content-Type", "audio/wav")

    case HTTPoison.post(url, file_data, headers, timeout: config.timeout) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        case Jason.decode(response_body) do
          {:ok, parsed_response} -> {:ok, parsed_response}
          {:error, reason} -> {:error, Error.json_error("Failed to parse response", reason)}
        end

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
