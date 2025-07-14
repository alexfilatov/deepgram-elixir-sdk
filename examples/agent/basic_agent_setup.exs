#!/usr/bin/env elixir

# Basic usage example for Deepgram's Agent API (AI Voice Agent)
# Usage: DEEPGRAM_API_KEY=your_api_key elixir basic_agent_setup.exs

Mix.install([
  {:deepgram, "~> 0.1"},
  {:jason, "~> 1.4"}
])

# Create a client with API key from environment variable
api_key = System.get_env("DEEPGRAM_API_KEY") || raise "DEEPGRAM_API_KEY environment variable is required"
client = Deepgram.new(api_key: api_key)

# This example demonstrates how to set up an AI Voice Agent
# In a real application, you would integrate this with audio input/output

# Agent configuration settings
agent_settings = %{
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
      provider: %{
        type: "open_ai",
        model: "gpt-4"
      },
      instructions: "You are a helpful assistant who provides concise, accurate information about weather forecasts.",
      functions: [
        %{
          name: "get_weather",
          description: "Get the current weather for a location",
          parameters: %{
            type: "object",
            properties: %{
              location: %{
                type: "string",
                description: "The city and state, e.g., San Francisco, CA"
              },
              unit: %{
                type: "string",
                enum: ["celsius", "fahrenheit"],
                description: "The temperature unit to use"
              }
            },
            required: ["location"]
          }
        }
      ]
    },
    speak: %{
      model: "aura-2-thalia-en",
      encoding: "linear16",
      provider: %{type: "deepgram"}
    }
  },
  greeting: "Hello! I'm your weather assistant. Ask me about the weather in any location."
}

IO.puts("Setting up an AI Voice Agent...")

# In a real application, you would start a WebSocket connection:
# {:ok, agent} = Deepgram.Agent.start_session(client, agent_settings)

# Simulated interaction for example purposes
IO.puts("\nSimulated agent interaction:")
IO.puts("------------------------------")
IO.puts("User: What's the weather in San Francisco?")
IO.puts("\nAgent would process this by:")
IO.puts("1. Converting speech to text using Deepgram Listen")
IO.puts("2. Processing with GPT-4 to understand the intent")
IO.puts("3. Calling the get_weather function")
IO.puts("4. Generating a response")
IO.puts("5. Converting the response to speech using Deepgram Speak")

# Example function call handler
weather_function_call = %{
  "function_call" => %{
    "name" => "get_weather",
    "arguments" => "{\"location\":\"San Francisco, CA\",\"unit\":\"celsius\"}"
  }
}

IO.puts("\nExample function call:")
IO.puts(Jason.encode!(weather_function_call, pretty: true))

IO.puts("\nExample function response:")
function_result = %{
  "temperature" => 18,
  "condition" => "Partly cloudy",
  "location" => "San Francisco, CA"
}
IO.puts(Jason.encode!(function_result, pretty: true))

IO.puts("\nIn a complete application, you would:")
IO.puts("- Handle WebSocket connections for real-time interaction")
IO.puts("- Process incoming audio from a microphone")
IO.puts("- Play the agent's audio responses")
IO.puts("- Implement function calls to external services")
IO.puts("- Manage the agent session lifecycle")
