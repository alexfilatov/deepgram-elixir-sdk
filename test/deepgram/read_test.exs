defmodule Deepgram.ReadTest do
  use ExUnit.Case, async: true
  import Deepgram.TestHelpers
  import Mox

  alias Deepgram.Error
  alias Deepgram.Read

  setup :verify_on_exit!

  describe "analyze/3" do
    test "successfully analyzes text" do
      client = create_test_client()
      text_source = %{text: "I love this product!"}
      options = %{sentiment: true, topics: true}

      expected_response = sample_analysis_response()
      expect_http_post_success(expected_response)

      assert {:ok, response} = Read.analyze(client, text_source, options)
      assert response == expected_response
    end

    test "handles empty text" do
      client = create_test_client()
      text_source = %{text: ""}

      assert {:error, %Error.TypeError{}} = Read.analyze(client, text_source)
    end

    test "handles invalid text source" do
      client = create_test_client()
      text_source = %{content: "I love this product!"}

      assert {:error, %Error.TypeError{}} = Read.analyze(client, text_source)
    end

    test "handles HTTP error" do
      client = create_test_client()
      text_source = %{text: "I love this product!"}

      expect_http_post_error(:timeout)

      assert {:error, %Error.HttpError{}} = Read.analyze(client, text_source)
    end

    test "handles API error" do
      client = create_test_client()
      text_source = %{text: "I love this product!"}

      expect_http_post_api_error(400, "Bad request")

      assert {:error, %Error.ApiError{status_code: 400}} = Read.analyze(client, text_source)
    end

    test "includes query parameters" do
      client = create_test_client()
      text_source = %{text: "I love this product!"}
      options = %{model: "nova-2", sentiment: true, topics: true, intents: true}

      expected_response = sample_analysis_response()
      expect_http_post_success(expected_response)

      assert {:ok, _response} = Read.analyze(client, text_source, options)
    end
  end

  describe "analyze_sentiment/3" do
    test "successfully analyzes sentiment" do
      client = create_test_client()
      text_source = %{text: "I love this product!"}

      expected_response = sample_analysis_response()
      expect_http_post_success(expected_response)

      assert {:ok, response} = Read.analyze_sentiment(client, text_source)
      assert response == expected_response
    end

    test "includes sentiment option" do
      client = create_test_client()
      text_source = %{text: "I love this product!"}
      options = %{model: "nova-2"}

      expected_response = sample_analysis_response()
      expect_http_post_success(expected_response)

      assert {:ok, _response} = Read.analyze_sentiment(client, text_source, options)
    end
  end

  describe "analyze_topics/3" do
    test "successfully analyzes topics" do
      client = create_test_client()
      text_source = %{text: "Let's discuss machine learning and AI."}

      expected_response = sample_analysis_response()
      expect_http_post_success(expected_response)

      assert {:ok, response} = Read.analyze_topics(client, text_source)
      assert response == expected_response
    end

    test "includes topics option" do
      client = create_test_client()
      text_source = %{text: "Let's discuss machine learning and AI."}
      options = %{model: "nova-2"}

      expected_response = sample_analysis_response()
      expect_http_post_success(expected_response)

      assert {:ok, _response} = Read.analyze_topics(client, text_source, options)
    end
  end

  describe "analyze_intents/3" do
    test "successfully analyzes intents" do
      client = create_test_client()
      text_source = %{text: "I want to cancel my subscription."}

      expected_response = sample_analysis_response()
      expect_http_post_success(expected_response)

      assert {:ok, response} = Read.analyze_intents(client, text_source)
      assert response == expected_response
    end

    test "includes intents option" do
      client = create_test_client()
      text_source = %{text: "I want to cancel my subscription."}
      options = %{model: "nova-2"}

      expected_response = sample_analysis_response()
      expect_http_post_success(expected_response)

      assert {:ok, _response} = Read.analyze_intents(client, text_source, options)
    end
  end

  describe "summarize/3" do
    test "successfully summarizes text" do
      client = create_test_client()
      text_source = %{text: "Long text that needs to be summarized..."}

      expected_response = sample_analysis_response()
      expect_http_post_success(expected_response)

      assert {:ok, response} = Read.summarize(client, text_source)
      assert response == expected_response
    end

    test "includes summarize option" do
      client = create_test_client()
      text_source = %{text: "Long text that needs to be summarized..."}
      options = %{model: "nova-2"}

      expected_response = sample_analysis_response()
      expect_http_post_success(expected_response)

      assert {:ok, _response} = Read.summarize(client, text_source, options)
    end
  end

  describe "summarize_with_model/4" do
    test "successfully summarizes text with custom model" do
      client = create_test_client()
      text_source = %{text: "Long text that needs to be summarized..."}
      model = "nova-2"

      expected_response = sample_analysis_response()
      expect_http_post_success(expected_response)

      assert {:ok, response} = Read.summarize_with_model(client, text_source, model)
      assert response == expected_response
    end

    test "includes model in summarize option" do
      client = create_test_client()
      text_source = %{text: "Long text that needs to be summarized..."}
      model = "nova-2"
      options = %{language: "en"}

      expected_response = sample_analysis_response()
      expect_http_post_success(expected_response)

      assert {:ok, _response} = Read.summarize_with_model(client, text_source, model, options)
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
end
