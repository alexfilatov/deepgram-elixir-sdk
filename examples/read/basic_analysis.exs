#!/usr/bin/env elixir

# Basic usage example for Deepgram's Read API (Text Intelligence)
# Usage: DEEPGRAM_API_KEY=your_api_key mix run basic_analysis.exs

# Create a client with API key from environment variable
api_key = System.get_env("DEEPGRAM_API_KEY") || raise "DEEPGRAM_API_KEY environment variable is required"
client = Deepgram.new(api_key: api_key)

# Text to analyze
text = """
I had a great experience with the new product. The customer service was excellent,
and they resolved my issue quickly. The quality exceeded my expectations, and I would
definitely recommend it to others looking for a reliable solution.
"""

IO.puts("Analyzing text for sentiment, topics, and summarization...\n")
IO.puts("Text: #{text}\n")

# Analyze text with multiple analysis types
# Note: language parameter is required for text intelligence
options = %{
  language: "en",   # Required: Language of the text (currently only "en" is supported)
  sentiment: true,  # Analyze sentiment
  topics: true,     # Detect topics
  summarize: true   # Generate a summary
}

case Deepgram.Read.analyze(client, %{text: text}, options) do
  {:ok, response} ->
    results = response["results"]
    
    # Print sentiment analysis results
    if Map.has_key?(results, "sentiments") do
      sentiment = results["sentiments"]["average"]
      IO.puts("\n=== Sentiment Analysis ===")
      IO.puts("Sentiment: #{sentiment["sentiment"]}")
      IO.puts("Score: #{sentiment["sentiment_score"]}")
    end

    # Print topic detection results
    if Map.has_key?(results, "topics") && results["topics"]["segments"] != nil do
      IO.puts("\n=== Topic Detection ===")
      results["topics"]["segments"]
      |> Enum.flat_map(fn segment -> segment["topics"] end)
      |> Enum.sort_by(fn t -> -t["confidence_score"] end)
      |> Enum.each(fn topic ->
        IO.puts("- #{topic["topic"]} (#{Float.round(topic["confidence_score"], 3)})")
      end)
    end

    # Print summary
    if Map.has_key?(results, "summary") do
      IO.puts("\n=== Summary ===")
      IO.puts(results["summary"]["text"])
    end

  {:error, error} ->
    IO.puts("Error: #{inspect(error)}")
end
