# Deepgram Elixir SDK

[![Hex.pm](https://img.shields.io/hexpm/v/deepgram.svg)](https://hex.pm/packages/deepgram)
[![Documentation](https://img.shields.io/badge/documentation-hexdocs-blue.svg)](https://hexdocs.pm/deepgram)

Unofficial Elixir SDK for [Deepgram](https://www.deepgram.com/). Power your apps with world-class speech and Language AI models.

## Features

- **Speech-to-Text**: Convert audio to text with high accuracy
- **Text-to-Speech**: Generate natural-sounding speech from text
- **Text Intelligence**: Extract insights from text with sentiment analysis, topic detection, and more
- **AI Voice Agent**: Build conversational AI applications
- **Management API**: Manage projects, API keys, and usage
- **WebSocket Support**: Real-time streaming for live applications
- **Async/Await**: Full support for asynchronous operations

## Installation

Add `deepgram` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:deepgram, "~> 0.1"}
  ]
end
```

## Configuration

Set your Deepgram API key as an environment variable:

```bash
export DEEPGRAM_API_KEY="your-deepgram-api-key"
```

Or configure it in your application:

```elixir
config :deepgram,
  api_key: System.get_env("DEEPGRAM_API_KEY")
```

## Quick Start

```elixir
# Create a client
client = Deepgram.new(api_key: "your-api-key")

# Transcribe audio from URL
{:ok, result} = Deepgram.Listen.transcribe_url(client, %{url: "https://example.com/audio.wav"})

# Synthesize speech
{:ok, audio_data} = Deepgram.Speak.synthesize(client, %{text: "Hello, world!"})

# Analyze text
{:ok, analysis} = Deepgram.Read.analyze(client, %{text: "I love this product!"}, %{sentiment: true})
```

## Documentation

### Speech-to-Text

#### Prerecorded Audio

```elixir
# From URL
{:ok, result} = Deepgram.Listen.transcribe_url(client, 
  %{url: "https://example.com/audio.wav"}, 
  %{model: "nova-2", punctuate: true, diarize: true}
)

# From file
{:ok, audio_data} = File.read("path/to/audio.wav")
{:ok, result} = Deepgram.Listen.transcribe_file(client, audio_data, %{model: "nova-2"})

# With callback (async)
{:ok, result} = Deepgram.Listen.transcribe_url_callback(client, 
  %{url: "https://example.com/audio.wav"}, 
  "https://your-callback-url.com/webhook",
  %{model: "nova-2"}
)
```

#### Live Audio Streaming

```elixir
# Start WebSocket connection
{:ok, websocket} = Deepgram.Listen.live_transcription(client, %{
  model: "nova-2",
  interim_results: true,
  punctuate: true
})

# Send audio data
Deepgram.Listen.WebSocket.send_audio(websocket, audio_chunk)

# Handle messages
receive do
  {:deepgram_result, result} -> 
    IO.puts("Transcript: #{result["channel"]["alternatives"] |> hd |> Map.get("transcript")}")
  {:deepgram_error, error} -> 
    IO.puts("Error: #{inspect(error)}")
end
```

### Text-to-Speech

#### Basic Synthesis

```elixir
# Generate audio
{:ok, audio_data} = Deepgram.Speak.synthesize(client, 
  %{text: "Hello, world!"}, 
  %{model: "aura-2-thalia-en", encoding: "linear16"}
)

# Save to file
{:ok, response} = Deepgram.Speak.save_to_file(client, "output.wav", 
  %{text: "Hello, world!"}, 
  %{model: "aura-2-thalia-en"}
)
```

#### Live Speech Synthesis

```elixir
# Start WebSocket connection
{:ok, websocket} = Deepgram.Speak.live_synthesis(client, %{
  model: "aura-2-thalia-en",
  encoding: "linear16",
  sample_rate: 16000
})

# Send text to synthesize
Deepgram.Speak.WebSocket.send_text(websocket, "Hello, this is streaming text-to-speech!")

# Handle audio data
receive do
  {:deepgram_audio, audio_data} -> 
    # Play or save audio data
    File.write("output.wav", audio_data, [:append])
end
```

### Text Intelligence

```elixir
# Sentiment analysis
{:ok, result} = Deepgram.Read.analyze_sentiment(client, %{text: "I love this product!"})

# Topic detection
{:ok, result} = Deepgram.Read.analyze_topics(client, %{text: "Let's discuss machine learning."})

# Intent recognition
{:ok, result} = Deepgram.Read.analyze_intents(client, %{text: "I want to cancel my subscription."})

# Text summarization
{:ok, result} = Deepgram.Read.summarize(client, %{text: "Long text to summarize..."})

# Combined analysis
{:ok, result} = Deepgram.Read.analyze(client, %{text: "Analyze this text"}, %{
  sentiment: true,
  topics: true,
  intents: true,
  summarize: true
})
```

### AI Voice Agent

```elixir
# Configure agent
settings = %{
  agent: %{
    listen: %{
      model: "nova-2",
      language: "en",
      smart_format: true,
      encoding: "linear16",
      sample_rate: 16000,
      channels: 1,
      provider: %{type: "deepgram"}
    },
    think: %{
      provider: %{type: "open_ai", model: "gpt-4"},
      instructions: "You are a helpful assistant."
    },
    speak: %{
      model: "aura-2-thalia-en",
      encoding: "linear16",
      provider: %{type: "deepgram"}
    }
  },
  greeting: "Hello! How can I help you today?"
}

# Start agent session
{:ok, agent} = Deepgram.Agent.start_session(client, settings)

# Send audio to agent
Deepgram.Agent.send_audio(agent, audio_chunk)

# Handle agent responses
receive do
  {:deepgram_audio, audio_data} -> 
    # Play agent's speech
    play_audio(audio_data)
  {:deepgram_function_call_request, request} -> 
    # Handle function calls
    result = handle_function_call(request)
    Deepgram.Agent.respond_to_function_call(agent, request["function_call_id"], result)
end
```

### Management API

```elixir
# Get projects
{:ok, projects} = Deepgram.Manage.get_projects(client)

# Create API key
{:ok, key} = Deepgram.Manage.create_key(client, project_id, %{
  comment: "My API key",
  scopes: ["usage:read", "usage:write"]
})

# Get usage
{:ok, usage} = Deepgram.Manage.get_usage_summary(client, project_id)

# Get balances
{:ok, balances} = Deepgram.Manage.get_balances(client, project_id)
```

## Error Handling

The SDK uses tagged tuples for error handling:

```elixir
case Deepgram.Listen.transcribe_url(client, %{url: "invalid-url"}) do
  {:ok, result} -> 
    # Handle success
    IO.puts("Transcription: #{result}")
  {:error, %Deepgram.Error.ApiError{status_code: 400, message: message}} -> 
    # Handle API error
    IO.puts("API Error: #{message}")
  {:error, %Deepgram.Error.HttpError{reason: reason}} -> 
    # Handle HTTP error
    IO.puts("HTTP Error: #{reason}")
  {:error, error} -> 
    # Handle other errors
    IO.puts("Error: #{inspect(error)}")
end
```

## Examples

This SDK includes comprehensive examples to help you get started with each feature:

### Interactive Livebook Examples

Interactive notebooks for exploring SDK features:

- [Speech-to-Text (Listen) Examples](examples/listen/transcription_examples.livemd)
- [Text-to-Speech (Speak) Examples](examples/speak/tts_examples.livemd)
- [Text Intelligence (Read) Examples](examples/read/text_intelligence_examples.livemd)
- [AI Voice Agent Examples](examples/agent/ai_agent_examples.livemd)

### Script Examples

Standalone scripts for quick implementation:

- [Basic Transcription](examples/listen/basic_transcription.exs)
- [Basic Speech Synthesis](examples/speak/basic_synthesis.exs)
- [Basic Text Analysis](examples/read/basic_analysis.exs)
- [Basic Agent Setup](examples/agent/basic_agent_setup.exs)

For more examples and documentation, see the [examples directory](examples/).

## Development

```bash
# Install dependencies
mix deps.get

# Run tests
mix test

# Generate documentation
mix docs

# Run linter
mix credo

# Run type checker
mix dialyzer

# Check for compilation errors
mix compile --warnings-as-errors
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- [Documentation](https://hexdocs.pm/deepgram)
- [API Reference](https://developers.deepgram.com/reference/)
- [Discord Community](https://discord.gg/xWRaCDBtW4)
- [GitHub Issues](https://github.com/deepgram/deepgram-elixir-sdk/issues)
- [Deepgram Dashboard](https://console.deepgram.com/)
