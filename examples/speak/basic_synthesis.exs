#!/usr/bin/env elixir

# Basic usage example for Deepgram's Speak API (Text-to-Speech)
# Usage: DEEPGRAM_API_KEY=your_api_key elixir basic_synthesis.exs

Mix.install([
  {:deepgram, "~> 0.1"},
  {:jason, "~> 1.4"}
])

# Create a client with API key from environment variable
api_key = System.get_env("DEEPGRAM_API_KEY") || raise "DEEPGRAM_API_KEY environment variable is required"
client = Deepgram.new(api_key: api_key)

# Text to synthesize
text = "Hello, this is the Deepgram Text-to-Speech API. It provides natural-sounding speech synthesis powered by state-of-the-art AI models."

IO.puts("Synthesizing speech from text...")
IO.puts("Text: #{text}")

# Synthesize speech with options
options = %{
  model: "aura-2-thalia-en",  # Voice model to use
  encoding: "linear16",        # Audio encoding format
  sample_rate: 24000,          # Sample rate in Hz
  container: "wav"             # Output container format
}

output_file = "output.wav"

case Deepgram.Speak.synthesize(client, %{text: text}, options) do
  {:ok, audio_data} ->
    # Save the audio to a file
    File.write!(output_file, audio_data)
    IO.puts("\nSpeech synthesis successful!")
    IO.puts("Saved audio to #{output_file}")
    IO.puts("File size: #{File.stat!(output_file).size} bytes")

  {:error, error} ->
    IO.puts("Error: #{inspect(error)}")
end
