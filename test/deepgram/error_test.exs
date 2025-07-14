defmodule Deepgram.ErrorTest do
  use ExUnit.Case, async: true

  alias Deepgram.Error

  describe "error creation functions" do
    test "authentication_error/1 creates AuthenticationError" do
      error = Error.authentication_error("Invalid credentials")

      assert %Error.AuthenticationError{} = error
      assert error.message == "Invalid credentials"
    end

    test "api_error/3 creates ApiError" do
      error = Error.api_error("Bad request", 400, "Invalid parameters")

      assert %Error.ApiError{} = error
      assert error.message == "Bad request"
      assert error.status_code == 400
      assert error.response_body == "Invalid parameters"
    end

    test "type_error/3 creates TypeError" do
      error = Error.type_error("Type mismatch", "string", "integer")

      assert %Error.TypeError{} = error
      assert error.message == "Type mismatch"
      assert error.expected == "string"
      assert error.actual == "integer"
    end

    test "http_error/2 creates HttpError" do
      error = Error.http_error("Connection failed", :timeout)

      assert %Error.HttpError{} = error
      assert error.message == "Connection failed"
      assert error.reason == :timeout
    end

    test "websocket_error/2 creates WebSocketError" do
      error = Error.websocket_error("Connection closed", :normal)

      assert %Error.WebSocketError{} = error
      assert error.message == "Connection closed"
      assert error.reason == :normal
    end

    test "json_error/2 creates JsonError" do
      error = Error.json_error("Invalid JSON", "{invalid}")

      assert %Error.JsonError{} = error
      assert error.message == "Invalid JSON"
      assert error.data == "{invalid}"
    end

    test "config_error/2 creates ConfigError" do
      error = Error.config_error("Missing config", :api_key)

      assert %Error.ConfigError{} = error
      assert error.message == "Missing config"
      assert error.key == :api_key
    end

    test "timeout_error/2 creates TimeoutError" do
      error = Error.timeout_error("Request timeout", 30_000)

      assert %Error.TimeoutError{} = error
      assert error.message == "Request timeout"
      assert error.timeout == 30_000
    end
  end

  describe "error struct constructors" do
    test "DeepgramError.new/2 creates DeepgramError" do
      error = Error.DeepgramError.new("General error", :some_reason)

      assert %Error.DeepgramError{} = error
      assert error.message == "General error"
      assert error.reason == :some_reason
    end

    test "ApiError.new/3 creates ApiError" do
      error = Error.ApiError.new("API error", 500, "Internal server error")

      assert %Error.ApiError{} = error
      assert error.message == "API error"
      assert error.status_code == 500
      assert error.response_body == "Internal server error"
    end

    test "TypeError.new/3 creates TypeError" do
      error = Error.TypeError.new("Type error", "map", "string")

      assert %Error.TypeError{} = error
      assert error.message == "Type error"
      assert error.expected == "map"
      assert error.actual == "string"
    end

    test "HttpError.new/2 creates HttpError" do
      error = Error.HttpError.new("HTTP error", :connection_refused)

      assert %Error.HttpError{} = error
      assert error.message == "HTTP error"
      assert error.reason == :connection_refused
    end

    test "WebSocketError.new/2 creates WebSocketError" do
      error = Error.WebSocketError.new("WebSocket error", :close)

      assert %Error.WebSocketError{} = error
      assert error.message == "WebSocket error"
      assert error.reason == :close
    end

    test "JsonError.new/2 creates JsonError" do
      error = Error.JsonError.new("JSON error", %{"invalid" => "data"})

      assert %Error.JsonError{} = error
      assert error.message == "JSON error"
      assert error.data == %{"invalid" => "data"}
    end

    test "ConfigError.new/2 creates ConfigError" do
      error = Error.ConfigError.new("Config error", :timeout)

      assert %Error.ConfigError{} = error
      assert error.message == "Config error"
      assert error.key == :timeout
    end

    test "TimeoutError.new/2 creates TimeoutError" do
      error = Error.TimeoutError.new("Timeout error", 60_000)

      assert %Error.TimeoutError{} = error
      assert error.message == "Timeout error"
      assert error.timeout == 60_000
    end
  end

  describe "error exception handling" do
    test "AuthenticationError can be raised" do
      assert_raise Error.AuthenticationError, "Invalid API key", fn ->
        raise Error.AuthenticationError, "Invalid API key"
      end
    end

    test "error structs can be used in pattern matching" do
      error = Error.api_error("Not found", 404, "Resource not found")

      case error do
        %Error.ApiError{status_code: 404, message: message} ->
          assert message == "Not found"

        _ ->
          flunk("Pattern match failed")
      end
    end
  end
end
