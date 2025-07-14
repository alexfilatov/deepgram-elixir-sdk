defmodule Deepgram do
  @moduledoc """
  Official Elixir SDK for Deepgram's speech-to-text, text-to-speech, and AI agent services.

  ## Usage

  First, create a client with your API key:

      iex> _client = Deepgram.new(api_key: "your-api-key")

  Then use the client to access various services:

      # Speech-to-Text
      Deepgram.Listen.transcribe_url(client, %{url: "https://example.com/audio.wav"})

      # Text-to-Speech
      Deepgram.Speak.synthesize(client, %{text: "Hello, world!"})

      # Text Intelligence
      Deepgram.Read.analyze(client, %{text: "Analyze this text."})

      # AI Agent
      Deepgram.Agent.create_session(client, %{})

  ## Configuration

  The client can be configured with various options:

      client = Deepgram.new(
        api_key: "your-api-key",
        base_url: "https://api.deepgram.com",
        timeout: 30_000,
        headers: %{"Custom-Header" => "value"}
      )

  You can also use environment variables:

      export DEEPGRAM_API_KEY="your-api-key"
      export DEEPGRAM_BASE_URL="https://api.deepgram.com"

  """

  alias Deepgram.Client
  alias Deepgram.Config

  @doc """
  Creates a new Deepgram client.

  ## Options

  - `:api_key` - Your Deepgram API key (required, or set via `DEEPGRAM_API_KEY` env var)
  - `:access_token` - OAuth 2.0 access token (alternative to API key)
  - `:base_url` - Base URL for API requests (default: "https://api.deepgram.com")
  - `:timeout` - Request timeout in milliseconds (default: 30_000)
  - `:headers` - Additional HTTP headers (default: %{})
  - `:options` - Additional options (default: %{})

  ## Examples

      iex> client = Deepgram.new(api_key: "your-api-key")
      iex> match?(%Deepgram.Client{}, client)
      true

      iex> client = Deepgram.new(access_token: "your-access-token")
      iex> match?(%Deepgram.Client{}, client)
      true

  """
  @spec new(keyword()) :: Client.t()
  def new(opts \\ []) do
    config = Config.new(opts)
    Client.new(config)
  end

  @doc """
  Returns the current version of the SDK.
  """
  @spec version() :: String.t()
  def version do
    Application.spec(:deepgram, :vsn) |> to_string()
  end
end
