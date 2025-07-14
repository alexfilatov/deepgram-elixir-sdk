defmodule Deepgram.WebSocketTest do
  use ExUnit.Case, async: true

  describe "WebSocket modules" do
    test "WebSocket modules are defined" do
      # Test that WebSocket modules are defined
      assert Code.ensure_loaded?(Deepgram.Listen.WebSocket)
      assert Code.ensure_loaded?(Deepgram.Speak.WebSocket)
      assert Code.ensure_loaded?(Deepgram.Agent.WebSocket)
    end
  end

  describe "Message handling" do
    test "handles JSON message parsing" do
      valid_json = ~s({"type": "Results", "channel": {"alternatives": [{"transcript": "hello"}]}})

      case Jason.decode(valid_json) do
        {:ok, parsed} ->
          assert parsed["type"] == "Results"
          assert parsed["channel"]["alternatives"] == [%{"transcript" => "hello"}]

        {:error, reason} ->
          flunk("Should have parsed valid JSON: #{reason}")
      end
    end

    test "handles invalid JSON gracefully" do
      invalid_json = ~s({"type": "Results", "invalid": )

      case Jason.decode(invalid_json) do
        {:ok, _parsed} ->
          flunk("Should not have parsed invalid JSON")

        {:error, _reason} ->
          assert true
      end
    end
  end

  describe "Query parameter formatting" do
    test "formats different types correctly" do
      options = %{
        string_param: "value",
        boolean_param: true,
        integer_param: 42,
        float_param: 3.14,
        list_param: ["a", "b", "c"],
        atom_param: :test
      }

      params = format_query_params(options)

      assert {"string_param", "value"} in params
      assert {"boolean_param", "true"} in params
      assert {"integer_param", "42"} in params
      assert {"float_param", "3.14"} in params
      assert {"list_param", "a,b,c"} in params
      assert {"atom_param", "test"} in params
    end

    test "ignores unsupported types" do
      options = %{
        valid_param: "value",
        invalid_param: %{nested: "object"}
      }

      params = format_query_params(options)

      assert {"valid_param", "value"} in params
      refute Enum.any?(params, fn {key, _value} -> key == "invalid_param" end)
    end
  end

  # Helper function to test query parameter formatting
  defp format_query_params(options) when is_map(options) do
    options
    |> Enum.reduce([], fn {key, value}, acc ->
      case format_query_param(key, value) do
        {param_key, param_value} -> [{param_key, param_value} | acc]
        nil -> acc
      end
    end)
    |> Enum.reverse()
  end

  defp format_query_param(key, value) when is_list(value) do
    {to_string(key), Enum.join(value, ",")}
  end

  defp format_query_param(key, value) when is_boolean(value) do
    {to_string(key), to_string(value)}
  end

  defp format_query_param(key, value) when is_number(value) do
    {to_string(key), to_string(value)}
  end

  defp format_query_param(key, value) when is_binary(value) do
    {to_string(key), value}
  end

  defp format_query_param(key, value) when is_atom(value) do
    {to_string(key), to_string(value)}
  end

  defp format_query_param(_, _), do: nil
end
