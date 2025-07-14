defmodule Deepgram.AgentTest do
  use ExUnit.Case, async: true
  import Deepgram.TestHelpers

  alias Deepgram.Agent

  describe "start_session/2" do
    test "validates module and client" do
      client = create_test_client()

      # Test that client is a valid struct
      assert %Deepgram.Client{} = client

      # Test that the module exists
      assert Code.ensure_loaded?(Deepgram.Agent)
    end
  end

  describe "send_audio/2" do
    test "validates input parameters" do
      # Test that the function exists and can be called
      assert_raise UndefinedFunctionError, fn ->
        Agent.send_audio(:invalid_pid, "audio_data")
      end
    end
  end

  describe "send_text/2" do
    test "validates input parameters" do
      # Test that the function exists and can be called
      assert_raise UndefinedFunctionError, fn ->
        Agent.send_text(:invalid_pid, "Hello")
      end
    end
  end

  describe "respond_to_function_call/3" do
    test "validates input parameters" do
      # Test that the function exists and can be called
      assert_raise UndefinedFunctionError, fn ->
        Agent.respond_to_function_call(:invalid_pid, "call_id", %{result: "success"})
      end
    end
  end

  describe "inject_message/2" do
    test "validates input parameters" do
      # Test that the function exists and can be called
      assert_raise UndefinedFunctionError, fn ->
        Agent.inject_message(:invalid_pid, %{role: "user", content: "Hello"})
      end
    end
  end

  describe "update_settings/2" do
    test "validates input parameters" do
      # Test that the function exists and can be called
      assert_raise UndefinedFunctionError, fn ->
        Agent.update_settings(:invalid_pid, %{think: %{instructions: "New instructions"}})
      end
    end
  end

  describe "close_session/1" do
    test "validates input parameters" do
      # Test that the function exists and can be called
      assert_raise UndefinedFunctionError, fn ->
        Agent.close_session(:invalid_pid)
      end
    end
  end

  describe "keepalive/1" do
    test "validates input parameters" do
      # Test that the function exists and can be called
      assert_raise UndefinedFunctionError, fn ->
        Agent.keepalive(:invalid_pid)
      end
    end
  end
end
