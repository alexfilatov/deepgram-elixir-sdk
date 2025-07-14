defmodule DeepgramTest do
  use ExUnit.Case
  doctest Deepgram

  test "creates a client successfully" do
    client = Deepgram.new(api_key: "test-key")
    assert %Deepgram.Client{} = client
    assert client.config.api_key == "test-key"
  end

  test "creates a client with environment variable" do
    System.put_env("DEEPGRAM_API_KEY", "env-test-key")
    client = Deepgram.new()
    assert %Deepgram.Client{} = client
    assert client.config.api_key == "env-test-key"
  end

  test "creates a client with access token" do
    client = Deepgram.new(access_token: "test-token")
    assert %Deepgram.Client{} = client
    assert client.config.access_token == "test-token"
  end

  test "returns version" do
    version = Deepgram.version()
    assert is_binary(version)
  end
end
