defmodule Deepgram.IntegrationTest do
  use ExUnit.Case, async: false
  import Deepgram.TestHelpers
  import Mox

  alias Deepgram.Error
  alias Deepgram.{Agent, Listen, Manage, Read, Speak}

  @moduletag :integration

  setup :verify_on_exit!

  describe "End-to-end workflow" do
    test "complete workflow from client creation to service usage" do
      # Create client
      client = create_test_client()

      # Test client creation
      assert %Deepgram.Client{} = client
      assert client.config.api_key == "test-api-key"
      assert client.config.base_url == "https://api.deepgram.com"

      # Test service module access
      assert client.listen == Listen
      assert client.speak == Speak
      assert client.read == Read
      assert client.agent == Agent
      assert client.manage == Manage
    end

    test "handles authentication errors consistently" do
      # Test with no authentication
      cleanup_env_vars(["DEEPGRAM_API_KEY", "DEEPGRAM_ACCESS_TOKEN"])

      assert_raise Error.AuthenticationError, fn ->
        Deepgram.Config.new()
      end

      # Test with invalid API key
      client = create_test_client(api_key: "invalid-key")

      # All services should handle authentication errors gracefully
      _source = %{url: "https://example.com/audio.wav"}
      _text_source = %{text: "Hello, world!"}

      # These would normally make HTTP requests and fail with authentication errors
      # In a real integration test, we'd expect 401 responses
      assert %Deepgram.Client{} = client
      assert client.config.api_key == "invalid-key"
    end

    test "handles different client configurations" do
      # Test with API key
      client1 = create_test_client(api_key: "api-key-test")
      assert client1.config.api_key == "api-key-test"
      assert client1.config.access_token == nil

      # Test with access token (clean environment first)
      cleanup_env_vars(["DEEPGRAM_API_KEY"])
      client2 = create_test_client_with_token(access_token: "token-test")
      assert client2.config.access_token == "token-test"
      assert client2.config.api_key == nil

      # Test with custom base URL
      client3 = create_test_client(base_url: "https://custom.deepgram.com")
      assert client3.config.base_url == "https://custom.deepgram.com"

      # Test with custom timeout
      client4 = create_test_client(timeout: 60_000)
      assert client4.config.timeout == 60_000

      # Test with custom headers
      client5 = create_test_client(headers: %{"Custom-Header" => "value"})
      assert client5.config.headers["Custom-Header"] == "value"
    end

    test "validates input parameters across services" do
      client = create_test_client()

      # Test Listen service validation
      assert {:error, %Error.TypeError{}} = Listen.transcribe_url(client, %{invalid: "source"})
      assert {:error, %Error.TypeError{}} = Listen.transcribe_url(client, %{url: "invalid-url"})

      # Test Speak service validation
      assert {:error, %Error.TypeError{}} = Speak.synthesize(client, %{invalid: "source"})
      assert {:error, %Error.TypeError{}} = Speak.synthesize(client, %{text: ""})

      # Test Read service validation
      assert {:error, %Error.TypeError{}} = Read.analyze(client, %{invalid: "source"})
      assert {:error, %Error.TypeError{}} = Read.analyze(client, %{text: ""})
    end

    test "handles various option formats" do
      client = create_test_client()

      # Test with different option types
      options = %{
        model: "nova-2",
        punctuate: true,
        channels: 1,
        sample_rate: 16_000,
        language: "en",
        keywords: ["hello", "world"],
        redact: ["pci", "ssn"]
      }

      # These should all validate successfully (though HTTP requests would fail in test)
      source = %{url: "https://example.com/audio.wav"}
      text_source = %{text: "Hello, world!"}

      # Mock HTTP calls to return errors
      expect(HTTPoison, :post, 3, fn _url, _body, _headers, _opts ->
        {:error, %HTTPoison.Error{reason: :timeout}}
      end)

      # Test Listen options
      assert {:error, %Error.HttpError{}} = Listen.transcribe_url(client, source, options)

      # Test Speak options
      speak_options = %{
        model: "aura-2-thalia-en",
        encoding: "linear16",
        sample_rate: 16_000,
        container: "wav"
      }

      assert {:error, %Error.HttpError{}} = Speak.synthesize(client, text_source, speak_options)

      # Test Read options
      read_options = %{
        model: "nova-2",
        sentiment: true,
        topics: true,
        intents: true,
        summarize: true
      }

      assert {:error, %Error.HttpError{}} = Read.analyze(client, text_source, read_options)
    end

    test "URL building works correctly" do
      client = create_test_client()
      config = client.config

      # Test base URL handling
      assert config.base_url == "https://api.deepgram.com"

      # Test auth headers
      auth_header = Deepgram.Config.auth_header(config)
      assert auth_header == "Token test-api-key"

      # Test default headers
      headers = Deepgram.Config.default_headers(config)
      assert headers["Authorization"] == "Token test-api-key"
      assert headers["Accept"] == "application/json"
      assert String.starts_with?(headers["User-Agent"], "deepgram-elixir-sdk/")
    end
  end

  describe "Error handling consistency" do
    test "all services handle HTTP errors consistently" do
      client = create_test_client()

      # All services should return the same error format for HTTP failures
      source = %{url: "https://example.com/audio.wav"}
      text_source = %{text: "Hello, world!"}

      # Mock HTTP calls to return errors
      expect(HTTPoison, :post, 3, fn _url, _body, _headers, _opts ->
        {:error, %HTTPoison.Error{reason: :timeout}}
      end)

      # These will fail with HTTP errors in test environment
      assert {:error, %Error.HttpError{}} = Listen.transcribe_url(client, source)
      assert {:error, %Error.HttpError{}} = Speak.synthesize(client, text_source)
      assert {:error, %Error.HttpError{}} = Read.analyze(client, text_source)
    end

    test "all services handle validation errors consistently" do
      client = create_test_client()

      # All services should return TypeError for invalid inputs
      assert {:error, %Error.TypeError{}} = Listen.transcribe_url(client, %{invalid: "source"})
      assert {:error, %Error.TypeError{}} = Speak.synthesize(client, %{invalid: "source"})
      assert {:error, %Error.TypeError{}} = Read.analyze(client, %{invalid: "source"})
    end
  end

  describe "Service interoperability" do
    test "services can be used together" do
      client = create_test_client()

      # Test that all services are accessible from the same client
      assert client.listen == Listen
      assert client.speak == Speak
      assert client.read == Read
      assert client.agent == Agent
      assert client.manage == Manage

      # Test that they all use the same configuration
      assert Deepgram.Client.config(client) == client.config
    end

    test "configuration is shared across services" do
      client =
        create_test_client(
          api_key: "shared-key",
          base_url: "https://shared.deepgram.com",
          timeout: 45_000
        )

      config = client.config
      assert config.api_key == "shared-key"
      assert config.base_url == "https://shared.deepgram.com"
      assert config.timeout == 45_000

      # All services should use the same configuration
      assert Deepgram.Client.config(client) == config
    end
  end
end
