#!/usr/bin/env elixir

# Basic usage example for Deepgram's Listen API (Speech-to-Text)
# Usage: DEEPGRAM_API_KEY=your_api_key elixir basic_transcription.exs

Mix.install([
  {:deepgram, "~> 0.1"},
  {:jason, "~> 1.4"}
])

# Create a client with API key from environment variable
api_key = System.get_env("DEEPGRAM_API_KEY") || raise "DEEPGRAM_API_KEY environment variable is required"
client = Deepgram.new(api_key: api_key)

# For this example, we'll demonstrate both URL and file transcription
# Since external URLs can be unreliable, we'll provide both options

# Option 1: Use a different public audio sample
audio_url = "https://www2.cs.uic.edu/~i101/SoundFiles/preamble10.wav"

IO.puts("Transcribing audio from URL: #{audio_url}...")

# Transcribe audio from URL with additional options
options = %{
  model: "nova-2",
  punctuate: true,
  diarize: true,
  smart_format: true
}

case Deepgram.Listen.transcribe_url(client, %{url: audio_url}, options) do
  {:ok, response} ->
    # Extract and print the transcript
    transcript =
      get_in(response, ["results", "channels", Access.at(0), "alternatives", Access.at(0), "transcript"])

    IO.puts("\n=== Transcription Result ===")
    IO.puts(transcript || "No transcript found")
    IO.puts("===========================\n")

    # Print some metadata if available
    if metadata = response["metadata"] do
      IO.puts("Audio duration: #{metadata["duration"]} seconds")
      if model_info = metadata["model_info"] do
        IO.puts("Model used: #{model_info["name"]}")
      end
      IO.puts("Channels: #{metadata["channels"]}")
    end

    # Show confidence scores if available
    if alternatives = get_in(response, ["results", "channels", Access.at(0), "alternatives"]) do
      IO.puts("\nConfidence scores:")
      Enum.with_index(alternatives)
      |> Enum.each(fn {alt, idx} ->
        confidence = alt["confidence"] || "N/A"
        IO.puts("  Alternative #{idx + 1}: #{confidence}")
      end)
    end

  {:error, error} ->
    IO.puts("Error occurred during transcription:")
    case error do
      %{message: message, status_code: code} when is_integer(code) ->
        IO.puts("  Status: #{code}")
        IO.puts("  Message: #{message}")
        if response_body = Map.get(error, :response_body) do
          case Jason.decode(response_body) do
            {:ok, decoded} -> IO.puts("  Details: #{inspect(decoded, pretty: true)}")
            _ -> IO.puts("  Raw response: #{response_body}")
          end
        end
      _ ->
        IO.puts("  #{inspect(error)}")
    end
end

# Alternative: File transcription example
# If you have a local audio file, you can transcribe it directly:
IO.puts("\n" <> String.duplicate("=", 50))
IO.puts("Alternative: Local file transcription example")
IO.puts("(This will only run if you have an audio file at the specified path)")

local_file_path = "sample_audio.wav"  # Change this to your audio file path

if File.exists?(local_file_path) do
  IO.puts("Transcribing local file: #{local_file_path}...")
  
  case File.read(local_file_path) do
    {:ok, audio_data} ->
      case Deepgram.Listen.transcribe_file(client, audio_data, options) do
        {:ok, file_response} ->
          file_transcript = get_in(file_response, ["results", "channels", Access.at(0), "alternatives", Access.at(0), "transcript"])
          IO.puts("\n=== Local File Transcription Result ===")
          IO.puts(file_transcript || "No transcript found")
          IO.puts("==========================================")
          
        {:error, error} ->
          IO.puts("Error transcribing local file: #{inspect(error)}")
      end
      
    {:error, error} ->
      IO.puts("Error reading file: #{error}")
  end
else
  IO.puts("Local file not found. To test file transcription:")
  IO.puts("1. Place an audio file (WAV, MP3, etc.) in the current directory")
  IO.puts("2. Update the 'local_file_path' variable with the correct filename")
  IO.puts("3. Run the script again")
end
