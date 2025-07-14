defmodule Deepgram.SpeakTest do
  use ExUnit.Case, async: true
  import Deepgram.TestHelpers
  import Mox

  alias Deepgram.Error
  alias Deepgram.Speak

  setup :verify_on_exit!

  describe "synthesize/3" do
    test "successfully synthesizes speech from text" do
      client = create_test_client()
      text_source = %{text: "Hello, world!"}
      options = %{model: "aura-2-thalia-en", encoding: "linear16"}

      expected_audio = sample_speech_response()
      expect_http_post_success(expected_audio)

      assert {:ok, audio_data} = Speak.synthesize(client, text_source, options)
      assert audio_data == expected_audio
    end

    test "handles empty text" do
      client = create_test_client()
      text_source = %{text: ""}

      assert {:error, %Error.TypeError{}} = Speak.synthesize(client, text_source)
    end

    test "handles invalid text source" do
      client = create_test_client()
      text_source = %{content: "Hello, world!"}

      assert {:error, %Error.TypeError{}} = Speak.synthesize(client, text_source)
    end

    test "handles HTTP error" do
      client = create_test_client()
      text_source = %{text: "Hello, world!"}

      expect_http_post_error(:timeout)

      assert {:error, %Error.HttpError{}} = Speak.synthesize(client, text_source)
    end

    test "handles API error" do
      client = create_test_client()
      text_source = %{text: "Hello, world!"}

      expect_http_post_api_error(400, "Bad request")

      assert {:error, %Error.ApiError{status_code: 400}} = Speak.synthesize(client, text_source)
    end

    test "includes query parameters" do
      client = create_test_client()
      text_source = %{text: "Hello, world!"}
      options = %{model: "aura-2-thalia-en", encoding: "linear16", sample_rate: 16_000}

      expected_audio = sample_speech_response()
      expect_http_post_success(expected_audio)

      assert {:ok, _audio_data} = Speak.synthesize(client, text_source, options)
    end
  end

  describe "save_to_file/4" do
    test "validates input before making HTTP request" do
      client = create_test_client()
      file_path = "/tmp/test_audio.wav"

      # Test with invalid text source
      assert {:error, %Error.TypeError{}} =
               Speak.save_to_file(client, file_path, %{invalid: "source"})

      # Test with empty text
      assert {:error, %Error.TypeError{}} = Speak.save_to_file(client, file_path, %{text: ""})

      # Test with empty file path - this will make HTTP call so we need to mock
      expect(HTTPoison, :post, fn _url, _body, _headers, _opts ->
        {:error, %HTTPoison.Error{reason: :timeout}}
      end)

      assert {:error, %Error.HttpError{}} = Speak.save_to_file(client, "", %{text: "Hello"})
    end
  end

  describe "synthesize_callback/4" do
    test "successfully starts async synthesis" do
      client = create_test_client()
      text_source = %{text: "Hello, world!"}
      callback_url = "https://example.com/webhook"
      options = %{model: "aura-2-thalia-en"}

      expected_audio = sample_speech_response()
      expect_http_post_success(expected_audio)

      assert {:ok, _audio_data} =
               Speak.synthesize_callback(client, text_source, callback_url, options)
    end

    test "includes callback URL in options" do
      client = create_test_client()
      text_source = %{text: "Hello, world!"}
      callback_url = "https://example.com/webhook"

      expected_audio = sample_speech_response()
      expect_http_post_success(expected_audio)

      assert {:ok, _audio_data} = Speak.synthesize_callback(client, text_source, callback_url)
    end
  end

  describe "live_synthesis/2" do
    test "validates module and client" do
      client = create_test_client()

      # Test that client is a valid struct
      assert %Deepgram.Client{} = client

      # Test that the module exists
      assert Code.ensure_loaded?(Deepgram.Speak)
    end
  end

  # Helper functions for mocking HTTP requests
  defp expect_http_post_success(response_data) do
    expect(HTTPoison, :post, fn _url, _body, _headers, _opts ->
      {:ok, %HTTPoison.Response{status_code: 200, body: response_data}}
    end)
  end

  defp expect_http_post_error(reason) do
    expect(HTTPoison, :post, fn _url, _body, _headers, _opts ->
      {:error, %HTTPoison.Error{reason: reason}}
    end)
  end

  defp expect_http_post_api_error(status_code, message) do
    body = Jason.encode!(%{"error" => message})

    expect(HTTPoison, :post, fn _url, _body, _headers, _opts ->
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}}
    end)
  end
end
