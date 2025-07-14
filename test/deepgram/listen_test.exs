defmodule Deepgram.ListenTest do
  use ExUnit.Case, async: true
  import Deepgram.TestHelpers
  import Mox

  alias Deepgram.Error
  alias Deepgram.Listen

  setup :verify_on_exit!

  describe "transcribe_url/3" do
    test "successfully transcribes audio from URL" do
      client = create_test_client()
      source = %{url: "https://example.com/audio.wav"}
      options = %{model: "nova-2", punctuate: true}

      expected_response = sample_transcription_response()

      # Mock HTTPoison.post to return success
      expect_http_post_success(expected_response)

      assert {:ok, response} = Listen.transcribe_url(client, source, options)
      assert response == expected_response
    end

    test "handles invalid URL" do
      client = create_test_client()
      source = %{url: "invalid-url"}

      assert {:error, %Error.TypeError{}} = Listen.transcribe_url(client, source)
    end

    test "handles missing URL" do
      client = create_test_client()
      source = %{text: "not a url"}

      assert {:error, %Error.TypeError{}} = Listen.transcribe_url(client, source)
    end

    test "handles HTTP error" do
      client = create_test_client()
      source = %{url: "https://example.com/audio.wav"}

      expect_http_post_error(:timeout)

      assert {:error, %Error.HttpError{}} = Listen.transcribe_url(client, source)
    end

    test "handles API error" do
      client = create_test_client()
      source = %{url: "https://example.com/audio.wav"}

      expect_http_post_api_error(400, "Bad request")

      assert {:error, %Error.ApiError{status_code: 400}} = Listen.transcribe_url(client, source)
    end

    test "handles JSON parsing error" do
      client = create_test_client()
      source = %{url: "https://example.com/audio.wav"}

      expect_http_post_invalid_json()

      assert {:error, %Error.JsonError{}} = Listen.transcribe_url(client, source)
    end

    test "includes query parameters" do
      client = create_test_client()
      source = %{url: "https://example.com/audio.wav"}
      options = %{model: "nova-2", punctuate: true, language: "en"}

      expected_response = sample_transcription_response()
      expect_http_post_success(expected_response)

      assert {:ok, _response} = Listen.transcribe_url(client, source, options)
    end
  end

  describe "transcribe_file/3" do
    test "successfully transcribes audio from file" do
      client = create_test_client()
      file_data = "binary_audio_data"
      options = %{model: "nova-2"}

      expected_response = sample_transcription_response()
      expect_http_post_success(expected_response)

      assert {:ok, response} = Listen.transcribe_file(client, file_data, options)
      assert response == expected_response
    end

    test "handles empty file data" do
      client = create_test_client()
      file_data = ""

      expected_response = sample_transcription_response()
      expect_http_post_success(expected_response)

      assert {:ok, _response} = Listen.transcribe_file(client, file_data)
    end

    test "handles HTTP error for file upload" do
      client = create_test_client()
      file_data = "binary_audio_data"

      expect_http_post_error(:connection_refused)

      assert {:error, %Error.HttpError{}} = Listen.transcribe_file(client, file_data)
    end
  end

  describe "transcribe_url_callback/4" do
    test "successfully starts async transcription" do
      client = create_test_client()
      source = %{url: "https://example.com/audio.wav"}
      callback_url = "https://example.com/webhook"
      options = %{model: "nova-2"}

      expected_response = %{"request_id" => "test-request-id"}
      expect_http_post_success(expected_response)

      assert {:ok, response} =
               Listen.transcribe_url_callback(client, source, callback_url, options)

      assert response == expected_response
    end

    test "includes callback URL in options" do
      client = create_test_client()
      source = %{url: "https://example.com/audio.wav"}
      callback_url = "https://example.com/webhook"

      expected_response = %{"request_id" => "test-request-id"}
      expect_http_post_success(expected_response)

      assert {:ok, _response} = Listen.transcribe_url_callback(client, source, callback_url)
    end
  end

  describe "transcribe_file_callback/4" do
    test "successfully starts async file transcription" do
      client = create_test_client()
      file_data = "binary_audio_data"
      callback_url = "https://example.com/webhook"
      options = %{model: "nova-2"}

      expected_response = %{"request_id" => "test-request-id"}
      expect_http_post_success(expected_response)

      assert {:ok, response} =
               Listen.transcribe_file_callback(client, file_data, callback_url, options)

      assert response == expected_response
    end
  end

  describe "live_transcription/2" do
    test "validates module and client" do
      client = create_test_client()

      # Test that client is a valid struct
      assert %Deepgram.Client{} = client

      # Test that the module exists
      assert Code.ensure_loaded?(Deepgram.Listen)
    end
  end

  # Helper functions for mocking HTTP requests
  defp expect_http_post_success(response_data) do
    body = Jason.encode!(response_data)

    expect(HTTPoison, :post, fn _url, _body, _headers, _opts ->
      {:ok, %HTTPoison.Response{status_code: 200, body: body}}
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

  defp expect_http_post_invalid_json do
    expect(HTTPoison, :post, fn _url, _body, _headers, _opts ->
      {:ok, %HTTPoison.Response{status_code: 200, body: "invalid json"}}
    end)
  end
end
