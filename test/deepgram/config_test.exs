defmodule Deepgram.ConfigTest do
  use ExUnit.Case, async: true
  import Deepgram.TestHelpers

  alias Deepgram.Config
  alias Deepgram.Error

  describe "new/1" do
    test "creates config with API key" do
      config = Config.new(api_key: "test-key")

      assert config.api_key == "test-key"
      assert config.access_token == nil
      assert config.base_url == "https://api.deepgram.com"
      assert config.timeout == 30_000
      assert config.headers == %{}
      assert config.options == %{}
    end

    test "creates config with access token" do
      config = Config.new(access_token: "test-token")

      assert config.api_key == nil
      assert config.access_token == "test-token"
      assert config.base_url == "https://api.deepgram.com"
    end

    test "creates config with custom base URL" do
      config = Config.new(api_key: "test-key", base_url: "https://custom.deepgram.com")

      assert config.base_url == "https://custom.deepgram.com"
    end

    test "creates config with custom timeout" do
      config = Config.new(api_key: "test-key", timeout: 60_000)

      assert config.timeout == 60_000
    end

    test "creates config with custom headers" do
      headers = %{"Custom-Header" => "value"}
      config = Config.new(api_key: "test-key", headers: headers)

      assert config.headers == headers
    end

    test "creates config with custom options" do
      options = %{custom_option: "value"}
      config = Config.new(api_key: "test-key", options: options)

      assert config.options == options
    end

    test "uses environment variables for API key" do
      setup_env_vars(%{"DEEPGRAM_API_KEY" => "env-api-key"})

      config = Config.new()

      assert config.api_key == "env-api-key"
    end

    test "uses environment variables for access token" do
      setup_env_vars(%{"DEEPGRAM_ACCESS_TOKEN" => "env-access-token"})

      config = Config.new()

      assert config.access_token == "env-access-token"
    end

    test "uses environment variables for base URL" do
      setup_env_vars(%{
        "DEEPGRAM_API_KEY" => "test-key",
        "DEEPGRAM_BASE_URL" => "https://env.deepgram.com"
      })

      config = Config.new()

      assert config.base_url == "https://env.deepgram.com"
    end

    test "prioritizes access token over API key" do
      cleanup_env_vars(["DEEPGRAM_API_KEY", "DEEPGRAM_ACCESS_TOKEN"])
      config = Config.new(api_key: "test-key", access_token: "test-token")

      assert config.access_token == "test-token"
      assert config.api_key == nil
    end

    test "prioritizes explicit options over environment variables" do
      setup_env_vars(%{"DEEPGRAM_API_KEY" => "env-key"})

      config = Config.new(api_key: "explicit-key")

      assert config.api_key == "explicit-key"
    end

    test "raises error when no authentication provided" do
      cleanup_env_vars(["DEEPGRAM_API_KEY", "DEEPGRAM_ACCESS_TOKEN"])

      assert_raise Error.AuthenticationError, fn ->
        Config.new()
      end
    end

    test "normalizes base URL" do
      config = Config.new(api_key: "test-key", base_url: "api.deepgram.com/")

      assert config.base_url == "https://api.deepgram.com"
    end

    test "handles URL with existing protocol" do
      config = Config.new(api_key: "test-key", base_url: "http://localhost:8080")

      assert config.base_url == "http://localhost:8080"
    end
  end

  describe "auth_header/1" do
    test "returns Bearer token for access token" do
      config = Config.new(access_token: "test-token")

      assert Config.auth_header(config) == "Bearer test-token"
    end

    test "returns Token for API key" do
      config = Config.new(api_key: "test-key")

      assert Config.auth_header(config) == "Token test-key"
    end

    test "prioritizes access token over API key" do
      config = Config.new(api_key: "test-key", access_token: "test-token")

      assert Config.auth_header(config) == "Bearer test-token"
    end
  end

  describe "default_headers/1" do
    test "returns default headers with authorization" do
      config = Config.new(api_key: "test-key")
      headers = Config.default_headers(config)

      assert headers["Accept"] == "application/json"
      assert headers["Authorization"] == "Token test-key"
      assert String.starts_with?(headers["User-Agent"], "deepgram-elixir-sdk/")
    end

    test "includes custom headers" do
      config = Config.new(api_key: "test-key", headers: %{"Custom-Header" => "value"})
      headers = Config.default_headers(config)

      assert headers["Custom-Header"] == "value"
    end

    test "custom headers override defaults" do
      config = Config.new(api_key: "test-key", headers: %{"Accept" => "text/plain"})
      headers = Config.default_headers(config)

      assert headers["Accept"] == "text/plain"
    end
  end

  describe "user_agent/0" do
    test "returns user agent string" do
      user_agent = Config.user_agent()

      assert String.contains?(user_agent, "deepgram-elixir-sdk/")
      assert String.contains?(user_agent, "elixir/")
    end
  end
end
