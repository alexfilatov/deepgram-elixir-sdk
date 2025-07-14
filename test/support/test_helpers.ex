defmodule Deepgram.TestHelpers do
  @moduledoc """
  Test helpers for Deepgram SDK tests.
  """

  import ExUnit.Callbacks

  alias Deepgram.Client
  alias Deepgram.Config

  @doc """
  Creates a test client with default configuration.
  """
  def create_test_client(opts \\ []) do
    default_opts = [
      api_key: "test-api-key",
      base_url: "https://api.deepgram.com",
      timeout: 30_000,
      headers: %{},
      options: %{}
    ]

    config = Config.new(Keyword.merge(default_opts, opts))
    Client.new(config)
  end

  @doc """
  Creates a test client with access token.
  """
  def create_test_client_with_token(opts \\ []) do
    default_opts = [
      access_token: "test-access-token",
      base_url: "https://api.deepgram.com",
      timeout: 30_000,
      headers: %{},
      options: %{}
    ]

    config = Config.new(Keyword.merge(default_opts, opts))
    Client.new(config)
  end

  @doc """
  Mock HTTP response.
  """
  def mock_http_response(status_code, body) when is_integer(status_code) and is_binary(body) do
    {:ok, %HTTPoison.Response{status_code: status_code, body: body}}
  end

  @doc """
  Mock HTTP error.
  """
  def mock_http_error(reason) do
    {:error, %HTTPoison.Error{reason: reason}}
  end

  @doc """
  Mock successful JSON response.
  """
  def mock_json_response(data, status_code \\ 200) do
    body = Jason.encode!(data)
    mock_http_response(status_code, body)
  end

  @doc """
  Mock API error response.
  """
  def mock_api_error_response(message, status_code \\ 400) do
    body = Jason.encode!(%{"error" => message})
    mock_http_response(status_code, body)
  end

  @doc """
  Sample transcription response.
  """
  def sample_transcription_response do
    %{
      "metadata" => %{
        "transaction_key" => "test-transaction-key",
        "request_id" => "test-request-id",
        "sha256" => "test-sha256",
        "created" => "2024-01-01T00:00:00Z",
        "duration" => 5.0,
        "channels" => 1,
        "models" => ["nova-2"]
      },
      "results" => %{
        "channels" => [
          %{
            "alternatives" => [
              %{
                "transcript" => "Hello, world!",
                "confidence" => 0.95,
                "words" => [
                  %{
                    "word" => "Hello",
                    "start" => 0.0,
                    "end" => 0.5,
                    "confidence" => 0.95,
                    "punctuated_word" => "Hello,"
                  },
                  %{
                    "word" => "world",
                    "start" => 0.6,
                    "end" => 1.0,
                    "confidence" => 0.95,
                    "punctuated_word" => "world!"
                  }
                ]
              }
            ]
          }
        ]
      }
    }
  end

  @doc """
  Sample speech synthesis response.
  """
  def sample_speech_response do
    "binary_audio_data"
  end

  @doc """
  Sample text analysis response.
  """
  def sample_analysis_response do
    %{
      "metadata" => %{
        "request_id" => "test-request-id",
        "created" => "2024-01-01T00:00:00Z",
        "language" => "en",
        "model_uuid" => "test-model-uuid",
        "input_tokens" => 10,
        "output_tokens" => 5
      },
      "results" => %{
        "sentiments" => %{
          "segments" => [
            %{
              "text" => "I love this product!",
              "start_word" => 0,
              "end_word" => 4,
              "sentiments" => [
                %{
                  "sentiment" => "positive",
                  "confidence_score" => 0.95
                }
              ]
            }
          ],
          "average" => %{
            "sentiment" => "positive",
            "confidence_score" => 0.95
          }
        }
      }
    }
  end

  @doc """
  Sample projects response.
  """
  def sample_projects_response do
    %{
      "projects" => [
        %{
          "project_id" => "test-project-id",
          "name" => "Test Project",
          "company" => "Test Company",
          "org_id" => "test-org-id",
          "created" => "2024-01-01T00:00:00Z",
          "updated" => "2024-01-01T00:00:00Z"
        }
      ]
    }
  end

  @doc """
  Sample API keys response.
  """
  def sample_keys_response do
    %{
      "api_keys" => [
        %{
          "key_id" => "test-key-id",
          "api_key" => "test-api-key",
          "comment" => "Test API key",
          "created" => "2024-01-01T00:00:00Z",
          "scopes" => ["usage:read"],
          "tags" => ["test"]
        }
      ]
    }
  end

  @doc """
  Sets up environment variables for testing.
  """
  def setup_env_vars(env_vars) do
    original_values =
      Enum.map(env_vars, fn {key, value} ->
        original = System.get_env(key)
        System.put_env(key, value)
        {key, original}
      end)

    on_exit(fn ->
      Enum.each(original_values, &restore_env_var/1)
    end)
  end

  # Helper function to restore environment variables
  defp restore_env_var({key, original}) do
    case original do
      nil -> System.delete_env(key)
      value -> System.put_env(key, value)
    end
  end

  @doc """
  Cleans up environment variables.
  """
  def cleanup_env_vars(keys) do
    Enum.each(keys, &System.delete_env/1)
  end
end
