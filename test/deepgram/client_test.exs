defmodule Deepgram.ClientTest do
  use ExUnit.Case, async: true
  import Deepgram.TestHelpers

  alias Deepgram.Client
  alias Deepgram.Config

  describe "new/1" do
    test "creates client with config" do
      config = Config.new(api_key: "test-key")
      client = Client.new(config)

      assert %Client{} = client
      assert client.config == config
      assert client.listen == Deepgram.Listen
      assert client.speak == Deepgram.Speak
      assert client.read == Deepgram.Read
      assert client.agent == Deepgram.Agent
      assert client.manage == Deepgram.Manage
    end
  end

  describe "config/1" do
    test "returns client configuration" do
      config = Config.new(api_key: "test-key")
      client = Client.new(config)

      assert Client.config(client) == config
    end
  end

  describe "service accessors" do
    setup do
      client = create_test_client()
      %{client: client}
    end

    test "listen/1 returns Listen module", %{client: client} do
      assert Client.listen(client) == Deepgram.Listen
    end

    test "speak/1 returns Speak module", %{client: client} do
      assert Client.speak(client) == Deepgram.Speak
    end

    test "read/1 returns Read module", %{client: client} do
      assert Client.read(client) == Deepgram.Read
    end

    test "agent/1 returns Agent module", %{client: client} do
      assert Client.agent(client) == Deepgram.Agent
    end

    test "manage/1 returns Manage module", %{client: client} do
      assert Client.manage(client) == Deepgram.Manage
    end
  end
end
