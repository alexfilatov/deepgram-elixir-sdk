# Deepgram Elixir SDK Examples

This directory contains examples demonstrating the features of the Deepgram Elixir SDK.

## Structure

- **listen/** - Speech-to-Text examples
- **speak/** - Text-to-Speech examples
- **read/** - Text Intelligence examples
- **agent/** - AI Voice Agent examples

## Running Examples

### Script Examples

For the `.exs` script examples, you can run them directly with:

```bash
DEEPGRAM_API_KEY=your_api_key elixir examples/[feature]/[example_file].exs
```

For example:

```bash
DEEPGRAM_API_KEY=your_api_key elixir examples/listen/basic_transcription.exs
```

### Livebook Examples

For the Livebook (`.livemd`) examples, you have two options:

1. Open them in [Livebook](https://livebook.dev/):

```bash
livebook server
```

Then navigate to the Livebook interface and open the desired `.livemd` file.

1. Use the [Livebook VSCode extension](https://marketplace.visualstudio.com/items?itemName=livebook.livebook-vscode) to open and run them directly in Visual Studio Code.

## Available Examples

### Speech-to-Text (Listen)

- **[basic_transcription.exs](listen/basic_transcription.exs)** - Simple script demonstrating how to transcribe audio from a URL
- **[transcription_examples.livemd](listen/transcription_examples.livemd)** - Interactive notebook with comprehensive Speech-to-Text examples

### Text-to-Speech (Speak)

- **[basic_synthesis.exs](speak/basic_synthesis.exs)** - Simple script demonstrating how to synthesize speech from text
- **[tts_examples.livemd](speak/tts_examples.livemd)** - Interactive notebook with comprehensive Text-to-Speech examples

### Text Intelligence (Read)

- **[basic_analysis.exs](read/basic_analysis.exs)** - Simple script demonstrating how to analyze text for sentiment, topics, and summaries
- **[text_intelligence_examples.livemd](read/text_intelligence_examples.livemd)** - Interactive notebook with comprehensive Text Intelligence examples

### AI Voice Agent

- **[basic_agent_setup.exs](agent/basic_agent_setup.exs)** - Simple script demonstrating how to configure an AI Voice Agent
- **[ai_agent_examples.livemd](agent/ai_agent_examples.livemd)** - Interactive notebook with comprehensive AI Agent examples

## Additional Resources

- [Deepgram Elixir SDK Documentation](https://hexdocs.pm/deepgram)
- [Deepgram API Documentation](https://developers.deepgram.com/docs)
- [GitHub Repository](https://github.com/deepgram/deepgram-elixir-sdk)
