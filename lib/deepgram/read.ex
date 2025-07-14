defmodule Deepgram.Read do
  @moduledoc """
  Text Intelligence services for the Deepgram API.

  The `Deepgram.Read` module provides advanced text analysis capabilities through
  Deepgram's Text Intelligence API. It enables developers to extract meaningful insights
  from text data through various analysis features.

  ## Key Features

  * **Sentiment Analysis** - Determine emotional tone and sentiment polarity in text
  * **Topic Detection** - Identify key topics and themes within content
  * **Intent Recognition** - Understand user goals and intentions from text
  * **Summarization** - Generate concise summaries of longer text content
  * **Entity Recognition** - Identify and extract named entities from text
  * **Combined Analysis** - Run multiple analysis types in a single API call
  * **Custom Model Support** - Use specialized models for different analysis needs

  ## Authentication

  All functions in this module require a properly configured `Deepgram.Client` struct,
  which can be created using `Deepgram.new/1`.

  Example:

      # Create client with API key
      client = Deepgram.new(api_key: System.get_env("DEEPGRAM_API_KEY"))
      
      # Or with OAuth token
      client = Deepgram.new(token: "your-oauth-token")

  ## Basic Usage

  Analyze text for sentiment:

      client = Deepgram.new(api_key: System.get_env("DEEPGRAM_API_KEY"))
      text_source = %{text: "I love this product! It's amazing and works perfectly."}
      # Note: language parameter defaults to "en" if not specified
      {:ok, response} = Deepgram.Read.analyze_sentiment(client, text_source)

  Analyze text for topics:

      text_source = %{text: "Let's discuss machine learning and artificial intelligence."}
      {:ok, response} = Deepgram.Read.analyze_topics(client, text_source)

  Summarize text content:

      long_text = %{text: "Long article or document content that needs to be summarized..."}
      {:ok, response} = Deepgram.Read.summarize(client, long_text)

  ## Advanced Usage

  Perform multiple analysis types in a single call:

      text_source = %{text: "I really enjoyed the customer service. The representative was very helpful."}
      options = %{
        language: "en",    # Required - currently only English is supported
        sentiment: true,
        topics: true,
        intents: true
      }
      {:ok, response} = Deepgram.Read.analyze(client, text_source, options)

  Use a specific model for summarization:

      {:ok, response} = Deepgram.Read.summarize_with_model(client, long_text, "nova-2")
  """

  alias Deepgram.Client
  alias Deepgram.Config
  alias Deepgram.Error
  alias Deepgram.Types.Read

  @api_version "v1"

  @doc """
  Analyzes text for intelligence features.

  ## Parameters

  - `client` - A `Deepgram.Client` struct
  - `text_source` - A map containing the text: `%{text: "Analyze this text."}`
  - `options` - Optional analysis options (see `t:Deepgram.Types.Read.analyze_options/0`)

  ## Examples

      iex> client = Deepgram.new(api_key: "your-api-key")
      iex> text_source = %{text: "I love this product! It's amazing and works perfectly."}
      iex> options = %{model: "nova-2", sentiment: true, topics: true}
      iex> {:ok, response} = Deepgram.Read.analyze(client, text_source, options)
      {:ok, %{metadata: %{...}, results: %{...}}}

  """
  @spec analyze(Client.t(), Read.text_source(), Read.analyze_options()) ::
          {:ok, Read.analyze_response()} | {:error, any()}
  def analyze(%Client{} = client, text_source, options \\ %{}) do
    with {:ok, validated_source} <- validate_text_source(text_source),
         {:ok, query_params} <- build_query_params(options),
         {:ok, response} <- make_request(client, "read", validated_source, query_params) do
      {:ok, response}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Analyzes text for sentiment.

  ## Parameters

  - `client` - A `Deepgram.Client` struct
  - `text_source` - A map containing the text: `%{text: "Analyze this text."}`
  - `options` - Optional analysis options

  ## Examples

      iex> client = Deepgram.new(api_key: "your-api-key")
      iex> text_source = %{text: "I love this product!"}
      iex> {:ok, response} = Deepgram.Read.analyze_sentiment(client, text_source)
      {:ok, %{metadata: %{...}, results: %{sentiments: %{...}}}}

  """
  @spec analyze_sentiment(Client.t(), Read.text_source(), Read.analyze_options()) ::
          {:ok, Read.analyze_response()} | {:error, any()}
  def analyze_sentiment(%Client{} = client, text_source, options \\ %{}) do
    options_with_sentiment = Map.put(options, :sentiment, true)
    analyze(client, text_source, options_with_sentiment)
  end

  @doc """
  Analyzes text for topics.

  ## Parameters

  - `client` - A `Deepgram.Client` struct
  - `text_source` - A map containing the text: `%{text: "Analyze this text."}`
  - `options` - Optional analysis options

  ## Examples

      iex> client = Deepgram.new(api_key: "your-api-key")
      iex> text_source = %{text: "Let's discuss machine learning and artificial intelligence."}
      iex> {:ok, response} = Deepgram.Read.analyze_topics(client, text_source)
      {:ok, %{metadata: %{...}, results: %{topics: %{...}}}}

  """
  @spec analyze_topics(Client.t(), Read.text_source(), Read.analyze_options()) ::
          {:ok, Read.analyze_response()} | {:error, any()}
  def analyze_topics(%Client{} = client, text_source, options \\ %{}) do
    options_with_topics = Map.put(options, :topics, true)
    analyze(client, text_source, options_with_topics)
  end

  @doc """
  Analyzes text for intents.

  ## Parameters

  - `client` - A `Deepgram.Client` struct
  - `text_source` - A map containing the text: `%{text: "Analyze this text."}`
  - `options` - Optional analysis options

  ## Examples

      iex> client = Deepgram.new(api_key: "your-api-key")
      iex> text_source = %{text: "I want to cancel my subscription."}
      iex> {:ok, response} = Deepgram.Read.analyze_intents(client, text_source)
      {:ok, %{metadata: %{...}, results: %{intents: %{...}}}}

  """
  @spec analyze_intents(Client.t(), Read.text_source(), Read.analyze_options()) ::
          {:ok, Read.analyze_response()} | {:error, any()}
  def analyze_intents(%Client{} = client, text_source, options \\ %{}) do
    options_with_intents = Map.put(options, :intents, true)
    analyze(client, text_source, options_with_intents)
  end

  @doc """
  Summarizes text.

  ## Parameters

  - `client` - A `Deepgram.Client` struct
  - `text_source` - A map containing the text: `%{text: "Text to summarize."}`
  - `options` - Optional analysis options

  ## Examples

      iex> client = Deepgram.new(api_key: "your-api-key")
      iex> text_source = %{text: "Long text that needs to be summarized..."}
      iex> {:ok, response} = Deepgram.Read.summarize(client, text_source)
      {:ok, %{metadata: %{...}, results: %{summary: %{...}}}}

  """
  @spec summarize(Client.t(), Read.text_source(), Read.analyze_options()) ::
          {:ok, Read.analyze_response()} | {:error, any()}
  def summarize(%Client{} = client, text_source, options \\ %{}) do
    options_with_summary = Map.put(options, :summarize, true)
    analyze(client, text_source, options_with_summary)
  end

  @doc """
  Summarizes text with a custom model.

  ## Parameters

  - `client` - A `Deepgram.Client` struct
  - `text_source` - A map containing the text: `%{text: "Text to summarize."}`
  - `model` - Summary model to use (e.g., "nova-2")
  - `options` - Optional analysis options

  ## Examples

      iex> client = Deepgram.new(api_key: "your-api-key")
      iex> text_source = %{text: "Long text that needs to be summarized..."}
      iex> {:ok, response} = Deepgram.Read.summarize_with_model(client, text_source, "nova-2")
      {:ok, %{metadata: %{...}, results: %{summary: %{...}}}}

  """
  @spec summarize_with_model(Client.t(), Read.text_source(), String.t(), Read.analyze_options()) ::
          {:ok, Read.analyze_response()} | {:error, any()}
  def summarize_with_model(%Client{} = client, text_source, model, options \\ %{}) do
    options_with_model_summary =
      options
      |> Map.put(:summarize, model)

    analyze(client, text_source, options_with_model_summary)
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
    # Ensure language parameter is set (required by Text Intelligence API)
    options_with_defaults = Map.put_new(options, :language, "en")
    
    query_params =
      options_with_defaults
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
    headers = Map.to_list(Map.put(base_headers, "Content-Type", "text/plain"))
    body = text_source.text

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

  defp build_url(%Config{base_url: base_url}, endpoint, query_params) do
    url = "#{base_url}/#{@api_version}/#{endpoint}"

    case query_params do
      [] -> url
      params -> "#{url}?#{URI.encode_query(params)}"
    end
  end
end
