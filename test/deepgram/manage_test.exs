defmodule Deepgram.ManageTest do
  use ExUnit.Case, async: true
  import Deepgram.TestHelpers
  import Mox

  alias Deepgram.Error
  alias Deepgram.Manage

  setup :verify_on_exit!

  describe "get_projects/1" do
    test "successfully gets projects" do
      client = create_test_client()
      expected_response = sample_projects_response()

      expect_http_get_success(expected_response)

      assert {:ok, response} = Manage.get_projects(client)
      assert response == expected_response
    end

    test "handles HTTP error" do
      client = create_test_client()

      expect_http_get_error(:timeout)

      assert {:error, %Error.HttpError{}} = Manage.get_projects(client)
    end

    test "handles API error" do
      client = create_test_client()

      expect_http_get_api_error(401, "Unauthorized")

      assert {:error, %Error.ApiError{status_code: 401}} = Manage.get_projects(client)
    end
  end

  describe "get_project/2" do
    test "successfully gets a project" do
      client = create_test_client()
      project_id = "test-project-id"

      expected_response = %{
        "project_id" => project_id,
        "name" => "Test Project",
        "company" => "Test Company"
      }

      expect_http_get_success(expected_response)

      assert {:ok, response} = Manage.get_project(client, project_id)
      assert response == expected_response
    end

    test "handles project not found" do
      client = create_test_client()
      project_id = "non-existent-project"

      expect_http_get_api_error(404, "Project not found")

      assert {:error, %Error.ApiError{status_code: 404}} = Manage.get_project(client, project_id)
    end
  end

  describe "delete_project/2" do
    test "successfully deletes a project" do
      client = create_test_client()
      project_id = "test-project-id"
      expected_response = %{"message" => "Project deleted successfully"}

      expect_http_delete_success(expected_response)

      assert {:ok, response} = Manage.delete_project(client, project_id)
      assert response == expected_response
    end
  end

  describe "get_keys/2" do
    test "successfully gets API keys" do
      client = create_test_client()
      project_id = "test-project-id"
      expected_response = sample_keys_response()

      expect_http_get_success(expected_response)

      assert {:ok, response} = Manage.get_keys(client, project_id)
      assert response == expected_response
    end
  end

  describe "get_key/3" do
    test "successfully gets a specific API key" do
      client = create_test_client()
      project_id = "test-project-id"
      key_id = "test-key-id"

      expected_response = %{
        "api_key" => %{
          "key_id" => key_id,
          "api_key" => "test-api-key"
        }
      }

      expect_http_get_success(expected_response)

      assert {:ok, response} = Manage.get_key(client, project_id, key_id)
      assert response == expected_response
    end
  end

  describe "create_key/3" do
    test "successfully creates an API key" do
      client = create_test_client()
      project_id = "test-project-id"

      options = %{
        comment: "Test API key",
        scopes: ["usage:read", "usage:write"],
        tags: ["test"]
      }

      expected_response = %{
        "api_key" => %{
          "key_id" => "new-key-id",
          "api_key" => "new-api-key",
          "comment" => "Test API key",
          "scopes" => ["usage:read", "usage:write"]
        }
      }

      expect_http_post_success(expected_response)

      assert {:ok, response} = Manage.create_key(client, project_id, options)
      assert response == expected_response
    end

    test "handles invalid scopes" do
      client = create_test_client()
      project_id = "test-project-id"
      options = %{scopes: ["invalid:scope"]}

      expect_http_post_api_error(400, "Invalid scope")

      assert {:error, %Error.ApiError{status_code: 400}} =
               Manage.create_key(client, project_id, options)
    end
  end

  describe "delete_key/3" do
    test "successfully deletes an API key" do
      client = create_test_client()
      project_id = "test-project-id"
      key_id = "test-key-id"
      expected_response = %{"message" => "API key deleted successfully"}

      expect_http_delete_success(expected_response)

      assert {:ok, response} = Manage.delete_key(client, project_id, key_id)
      assert response == expected_response
    end
  end

  describe "get_members/2" do
    test "successfully gets project members" do
      client = create_test_client()
      project_id = "test-project-id"

      expected_response = %{
        "members" => [
          %{
            "member_id" => "test-member-id",
            "email" => "test@example.com",
            "first_name" => "Test",
            "last_name" => "User"
          }
        ]
      }

      expect_http_get_success(expected_response)

      assert {:ok, response} = Manage.get_members(client, project_id)
      assert response == expected_response
    end
  end

  describe "remove_member/3" do
    test "successfully removes a member" do
      client = create_test_client()
      project_id = "test-project-id"
      member_id = "test-member-id"
      expected_response = %{"message" => "Member removed successfully"}

      expect_http_delete_success(expected_response)

      assert {:ok, response} = Manage.remove_member(client, project_id, member_id)
      assert response == expected_response
    end
  end

  describe "get_usage_requests/2" do
    test "successfully gets usage requests" do
      client = create_test_client()
      project_id = "test-project-id"

      expected_response = %{
        "page" => 1,
        "limit" => 50,
        "requests" => [
          %{
            "request_id" => "test-request-id",
            "created" => "2024-01-01T00:00:00Z",
            "path" => "/v1/listen"
          }
        ]
      }

      expect_http_get_success(expected_response)

      assert {:ok, response} = Manage.get_usage_requests(client, project_id)
      assert response == expected_response
    end
  end

  describe "get_usage_summary/2" do
    test "successfully gets usage summary" do
      client = create_test_client()
      project_id = "test-project-id"

      expected_response = %{
        "start" => "2024-01-01T00:00:00Z",
        "end" => "2024-01-31T23:59:59Z",
        "usage" => %{
          "requests" => 1000,
          "hours" => 10.5
        }
      }

      expect_http_get_success(expected_response)

      assert {:ok, response} = Manage.get_usage_summary(client, project_id)
      assert response == expected_response
    end
  end

  describe "get_balances/2" do
    test "successfully gets balances" do
      client = create_test_client()
      project_id = "test-project-id"

      expected_response = %{
        "balances" => [
          %{
            "balance_id" => "test-balance-id",
            "amount" => 100.0,
            "units" => "USD"
          }
        ]
      }

      expect_http_get_success(expected_response)

      assert {:ok, response} = Manage.get_balances(client, project_id)
      assert response == expected_response
    end
  end

  describe "get_models/2" do
    test "successfully gets models" do
      client = create_test_client()
      project_id = "test-project-id"

      expected_response = %{
        "stt" => [
          %{
            "name" => "nova-2",
            "canonical_name" => "nova-2-general",
            "architecture" => "nova"
          }
        ],
        "tts" => [
          %{
            "name" => "aura-2-thalia-en",
            "canonical_name" => "aura-2-thalia-en",
            "architecture" => "aura"
          }
        ]
      }

      expect_http_get_success(expected_response)

      assert {:ok, response} = Manage.get_models(client, project_id)
      assert response == expected_response
    end
  end

  describe "get_model/3" do
    test "successfully gets a specific model" do
      client = create_test_client()
      project_id = "test-project-id"
      model_id = "nova-2"

      expected_response = %{
        "name" => "nova-2",
        "canonical_name" => "nova-2-general",
        "architecture" => "nova",
        "language" => "en",
        "version" => "2024-01-01",
        "uuid" => "test-model-uuid"
      }

      expect_http_get_success(expected_response)

      assert {:ok, response} = Manage.get_model(client, project_id, model_id)
      assert response == expected_response
    end
  end

  # Helper functions for mocking HTTP requests
  defp expect_http_get_success(response_data) do
    body = Jason.encode!(response_data)

    expect(HTTPoison, :get, fn _url, _headers, _opts ->
      {:ok, %HTTPoison.Response{status_code: 200, body: body}}
    end)
  end

  defp expect_http_get_error(reason) do
    expect(HTTPoison, :get, fn _url, _headers, _opts ->
      {:error, %HTTPoison.Error{reason: reason}}
    end)
  end

  defp expect_http_get_api_error(status_code, message) do
    body = Jason.encode!(%{"error" => message})

    expect(HTTPoison, :get, fn _url, _headers, _opts ->
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}}
    end)
  end

  defp expect_http_post_success(response_data) do
    body = Jason.encode!(response_data)

    expect(HTTPoison, :post, fn _url, _body, _headers, _opts ->
      {:ok, %HTTPoison.Response{status_code: 200, body: body}}
    end)
  end

  defp expect_http_post_api_error(status_code, message) do
    body = Jason.encode!(%{"error" => message})

    expect(HTTPoison, :post, fn _url, _body, _headers, _opts ->
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}}
    end)
  end

  defp expect_http_delete_success(response_data) do
    body = Jason.encode!(response_data)

    expect(HTTPoison, :delete, fn _url, _headers, _opts ->
      {:ok, %HTTPoison.Response{status_code: 200, body: body}}
    end)
  end
end
