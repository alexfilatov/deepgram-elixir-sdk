defmodule Deepgram.Manage do
  @moduledoc """
  Management API services for the Deepgram API.

  This module provides project and key management capabilities including
  project operations, API key management, member management, and usage tracking.
  """

  alias Deepgram.Client
  alias Deepgram.Config
  alias Deepgram.Error
  alias Deepgram.Types.Manage

  @api_version "v1"

  # Project Management

  @doc """
  Gets all projects accessible by the API key.

  ## Parameters

  - `client` - A `Deepgram.Client` struct

  ## Examples

      iex> client = Deepgram.new(api_key: "your-api-key")
      iex> {:ok, projects} = Deepgram.Manage.get_projects(client)
      {:ok, %{projects: [%{project_id: "...", name: "...", ...}]}}

  """
  @spec get_projects(Client.t()) :: {:ok, Manage.projects_response()} | {:error, any()}
  def get_projects(%Client{} = client) do
    make_request(client, :get, "projects")
  end

  @doc """
  Gets a specific project by ID.

  ## Parameters

  - `client` - A `Deepgram.Client` struct
  - `project_id` - The project ID

  ## Examples

      iex> client = Deepgram.new(api_key: "your-api-key")
      iex> {:ok, project} = Deepgram.Manage.get_project(client, "project-id")
      {:ok, %{project_id: "...", name: "...", ...}}

  """
  @spec get_project(Client.t(), String.t()) :: {:ok, Manage.project()} | {:error, any()}
  def get_project(%Client{} = client, project_id) do
    make_request(client, :get, "projects/#{project_id}")
  end

  @doc """
  Deletes a project.

  ## Parameters

  - `client` - A `Deepgram.Client` struct
  - `project_id` - The project ID

  ## Examples

      iex> client = Deepgram.new(api_key: "your-api-key")
      iex> {:ok, message} = Deepgram.Manage.delete_project(client, "project-id")
      {:ok, %{message: "Project deleted successfully"}}

  """
  @spec delete_project(Client.t(), String.t()) :: {:ok, Manage.message()} | {:error, any()}
  def delete_project(%Client{} = client, project_id) do
    make_request(client, :delete, "projects/#{project_id}")
  end

  # Key Management

  @doc """
  Gets all API keys for a project.

  ## Parameters

  - `client` - A `Deepgram.Client` struct
  - `project_id` - The project ID

  ## Examples

      iex> client = Deepgram.new(api_key: "your-api-key")
      iex> {:ok, keys} = Deepgram.Manage.get_keys(client, "project-id")
      {:ok, %{api_keys: [%{key_id: "...", api_key: "...", ...}]}}

  """
  @spec get_keys(Client.t(), String.t()) :: {:ok, Manage.keys_response()} | {:error, any()}
  def get_keys(%Client{} = client, project_id) do
    make_request(client, :get, "projects/#{project_id}/keys")
  end

  @doc """
  Gets a specific API key.

  ## Parameters

  - `client` - A `Deepgram.Client` struct
  - `project_id` - The project ID
  - `key_id` - The API key ID

  ## Examples

      iex> client = Deepgram.new(api_key: "your-api-key")
      iex> {:ok, key} = Deepgram.Manage.get_key(client, "project-id", "key-id")
      {:ok, %{api_key: %{key_id: "...", api_key: "...", ...}}}

  """
  @spec get_key(Client.t(), String.t(), String.t()) ::
          {:ok, Manage.key_response()} | {:error, any()}
  def get_key(%Client{} = client, project_id, key_id) do
    make_request(client, :get, "projects/#{project_id}/keys/#{key_id}")
  end

  @doc """
  Creates a new API key.

  ## Parameters

  - `client` - A `Deepgram.Client` struct
  - `project_id` - The project ID
  - `options` - Key creation options (see `t:t:Deepgram.Types.Manage.key_options/0`)

  ## Examples

      iex> client = Deepgram.new(api_key: "your-api-key")
      iex> options = %{comment: "My API key", scopes: ["usage:read"], tags: ["production"]}
      iex> {:ok, key} = Deepgram.Manage.create_key(client, "project-id", options)
      {:ok, %{api_key: %{key_id: "...", api_key: "...", ...}}}

  """
  @spec create_key(Client.t(), String.t(), Manage.key_options()) ::
          {:ok, Manage.key_response()} | {:error, any()}
  def create_key(%Client{} = client, project_id, options) do
    make_request(client, :post, "projects/#{project_id}/keys", options)
  end

  @doc """
  Deletes an API key.

  ## Parameters

  - `client` - A `Deepgram.Client` struct
  - `project_id` - The project ID
  - `key_id` - The API key ID

  ## Examples

      iex> client = Deepgram.new(api_key: "your-api-key")
      iex> {:ok, message} = Deepgram.Manage.delete_key(client, "project-id", "key-id")
      {:ok, %{message: "API key deleted successfully"}}

  """
  @spec delete_key(Client.t(), String.t(), String.t()) ::
          {:ok, Manage.message()} | {:error, any()}
  def delete_key(%Client{} = client, project_id, key_id) do
    make_request(client, :delete, "projects/#{project_id}/keys/#{key_id}")
  end

  # Member Management

  @doc """
  Gets all members of a project.

  ## Parameters

  - `client` - A `Deepgram.Client` struct
  - `project_id` - The project ID

  ## Examples

      iex> client = Deepgram.new(api_key: "your-api-key")
      iex> {:ok, members} = Deepgram.Manage.get_members(client, "project-id")
      {:ok, %{members: [%{member_id: "...", email: "...", ...}]}}

  """
  @spec get_members(Client.t(), String.t()) :: {:ok, Manage.members_response()} | {:error, any()}
  def get_members(%Client{} = client, project_id) do
    make_request(client, :get, "projects/#{project_id}/members")
  end

  @doc """
  Removes a member from a project.

  ## Parameters

  - `client` - A `Deepgram.Client` struct
  - `project_id` - The project ID
  - `member_id` - The member ID

  ## Examples

      iex> client = Deepgram.new(api_key: "your-api-key")
      iex> {:ok, message} = Deepgram.Manage.remove_member(client, "project-id", "member-id")
      {:ok, %{message: "Member removed successfully"}}

  """
  @spec remove_member(Client.t(), String.t(), String.t()) ::
          {:ok, Manage.message()} | {:error, any()}
  def remove_member(%Client{} = client, project_id, member_id) do
    make_request(client, :delete, "projects/#{project_id}/members/#{member_id}")
  end

  # Usage Management

  @doc """
  Gets usage requests for a project.

  ## Parameters

  - `client` - A `Deepgram.Client` struct
  - `project_id` - The project ID

  ## Examples

      iex> client = Deepgram.new(api_key: "your-api-key")
      iex> {:ok, usage} = Deepgram.Manage.get_usage_requests(client, "project-id")
      {:ok, %{page: 1, limit: 50, requests: [%{request_id: "...", ...}]}}

  """
  @spec get_usage_requests(Client.t(), String.t()) ::
          {:ok, Manage.usage_requests_response()} | {:error, any()}
  def get_usage_requests(%Client{} = client, project_id) do
    make_request(client, :get, "projects/#{project_id}/requests")
  end

  @doc """
  Gets usage summary for a project.

  ## Parameters

  - `client` - A `Deepgram.Client` struct
  - `project_id` - The project ID

  ## Examples

      iex> client = Deepgram.new(api_key: "your-api-key")
      iex> {:ok, usage} = Deepgram.Manage.get_usage_summary(client, "project-id")
      {:ok, %{start: "...", end: "...", usage: %{...}}}

  """
  @spec get_usage_summary(Client.t(), String.t()) ::
          {:ok, Manage.usage_response()} | {:error, any()}
  def get_usage_summary(%Client{} = client, project_id) do
    make_request(client, :get, "projects/#{project_id}/usage")
  end

  # Balance Management

  @doc """
  Gets all balances for a project.

  ## Parameters

  - `client` - A `Deepgram.Client` struct
  - `project_id` - The project ID

  ## Examples

      iex> client = Deepgram.new(api_key: "your-api-key")
      iex> {:ok, balances} = Deepgram.Manage.get_balances(client, "project-id")
      {:ok, %{balances: [%{balance_id: "...", amount: 100.0, ...}]}}

  """
  @spec get_balances(Client.t(), String.t()) ::
          {:ok, Manage.balances_response()} | {:error, any()}
  def get_balances(%Client{} = client, project_id) do
    make_request(client, :get, "projects/#{project_id}/balances")
  end

  # Model Management

  @doc """
  Gets all available models for a project.

  ## Parameters

  - `client` - A `Deepgram.Client` struct
  - `project_id` - The project ID

  ## Examples

      iex> client = Deepgram.new(api_key: "your-api-key")
      iex> {:ok, models} = Deepgram.Manage.get_models(client, "project-id")
      {:ok, %{stt: [...], tts: [...], read: [...]}}

  """
  @spec get_models(Client.t(), String.t()) :: {:ok, Manage.models_response()} | {:error, any()}
  def get_models(%Client{} = client, project_id) do
    make_request(client, :get, "projects/#{project_id}/models")
  end

  @doc """
  Gets a specific model by ID.

  ## Parameters

  - `client` - A `Deepgram.Client` struct
  - `project_id` - The project ID
  - `model_id` - The model ID

  ## Examples

      iex> client = Deepgram.new(api_key: "your-api-key")
      iex> {:ok, model} = Deepgram.Manage.get_model(client, "project-id", "model-id")
      {:ok, %{name: "nova-2", canonical_name: "...", ...}}

  """
  @spec get_model(Client.t(), String.t(), String.t()) ::
          {:ok, Manage.model_response()} | {:error, any()}
  def get_model(%Client{} = client, project_id, model_id) do
    make_request(client, :get, "projects/#{project_id}/models/#{model_id}")
  end

  # Private helper functions

  defp make_request(%Client{config: config}, method, endpoint, body \\ nil) do
    url = build_url(config, endpoint)
    headers = Config.default_headers(config)

    request_body = if body, do: Jason.encode!(body), else: ""

    case method do
      :get -> HTTPoison.get(url, headers, timeout: config.timeout)
      :post -> HTTPoison.post(url, request_body, headers, timeout: config.timeout)
      :delete -> HTTPoison.delete(url, headers, timeout: config.timeout)
    end
    |> handle_response()
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: status_code, body: body}})
       when status_code in 200..299 do
    case Jason.decode(body) do
      {:ok, parsed_response} -> {:ok, parsed_response}
      {:error, reason} -> {:error, Error.json_error("Failed to parse response", reason)}
    end
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: status_code, body: body}}) do
    {:error, Error.api_error("API request failed", status_code, body)}
  end

  defp handle_response({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, Error.http_error("HTTP request failed", reason)}
  end

  defp build_url(%Config{base_url: base_url}, endpoint) do
    "#{base_url}/#{@api_version}/#{endpoint}"
  end
end
