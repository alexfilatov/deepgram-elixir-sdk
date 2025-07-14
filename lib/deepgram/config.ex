defmodule Deepgram.Config do
  @moduledoc """
  Configuration for the Deepgram client.

  This module handles configuration options for the Deepgram client,
  including API keys, access tokens, base URLs, and other settings.
  """

  alias Deepgram.Error

  @type t :: %__MODULE__{
          api_key: String.t() | nil,
          access_token: String.t() | nil,
          base_url: String.t(),
          timeout: integer(),
          headers: map(),
          options: map()
        }

  @enforce_keys [:base_url, :timeout]
  defstruct [
    :api_key,
    :access_token,
    :base_url,
    :timeout,
    headers: %{},
    options: %{}
  ]

  @default_base_url "https://api.deepgram.com"
  @default_timeout 30_000

  @doc """
  Creates a new configuration.

  ## Options

  - `:api_key` - Your Deepgram API key (required, or set via `DEEPGRAM_API_KEY` env var)
  - `:access_token` - OAuth 2.0 access token (alternative to API key)
  - `:base_url` - Base URL for API requests (default: "https://api.deepgram.com")
  - `:timeout` - Request timeout in milliseconds (default: 30_000)
  - `:headers` - Additional HTTP headers (default: %{})
  - `:options` - Additional options (default: %{})

  ## Examples

      iex> config = Deepgram.Config.new(api_key: "your-api-key")
      %Deepgram.Config{...}

      iex> config = Deepgram.Config.new(access_token: "your-access-token")
      %Deepgram.Config{...}

      iex> config = Deepgram.Config.new()  # Uses DEEPGRAM_API_KEY env var
      %Deepgram.Config{...}

  """
  @spec new(keyword()) :: t()
  def new(opts \\ []) do
    api_key = get_api_key(opts)
    access_token = get_access_token(opts)
    base_url = get_base_url(opts)
    timeout = get_timeout(opts)
    headers = get_headers(opts)
    options = get_options(opts)

    # Validate authentication
    if is_nil(api_key) and is_nil(access_token) do
      raise Error.AuthenticationError, "Neither API key nor access token provided"
    end

    # Prioritize access token over API key
    {final_api_key, final_access_token} =
      if access_token do
        {nil, access_token}
      else
        {api_key, nil}
      end

    %__MODULE__{
      api_key: final_api_key,
      access_token: final_access_token,
      base_url: base_url,
      timeout: timeout,
      headers: headers,
      options: options
    }
  end

  @doc """
  Returns the authorization header value based on the configuration.

  Prioritizes access token over API key for authentication.
  """
  @spec auth_header(t()) :: String.t()
  def auth_header(%__MODULE__{access_token: access_token}) when is_binary(access_token) do
    "Bearer #{access_token}"
  end

  def auth_header(%__MODULE__{api_key: api_key}) when is_binary(api_key) do
    "Token #{api_key}"
  end

  @doc """
  Returns the default HTTP headers for requests.
  """
  @spec default_headers(t()) :: map()
  def default_headers(%__MODULE__{headers: custom_headers} = config) do
    Map.merge(
      %{
        "Accept" => "application/json",
        "Authorization" => auth_header(config),
        "User-Agent" => user_agent()
      },
      custom_headers
    )
  end

  @doc """
  Returns the user agent string.
  """
  @spec user_agent() :: String.t()
  def user_agent do
    version = Application.spec(:deepgram, :vsn) |> to_string()
    elixir_version = System.version()
    "deepgram-elixir-sdk/#{version} elixir/#{elixir_version}"
  end

  # Private helper functions

  defp get_api_key(opts) do
    case Keyword.get(opts, :api_key) do
      nil -> System.get_env("DEEPGRAM_API_KEY")
      key -> key
    end
  end

  defp get_access_token(opts) do
    case Keyword.get(opts, :access_token) do
      nil -> System.get_env("DEEPGRAM_ACCESS_TOKEN")
      token -> token
    end
  end

  defp get_base_url(opts) do
    case Keyword.get(opts, :base_url) do
      nil -> System.get_env("DEEPGRAM_BASE_URL", @default_base_url)
      url -> url
    end
    |> normalize_url()
  end

  defp get_timeout(opts) do
    case Keyword.get(opts, :timeout) do
      nil -> @default_timeout
      timeout when is_integer(timeout) and timeout > 0 -> timeout
      _ -> @default_timeout
    end
  end

  defp get_headers(opts) do
    Keyword.get(opts, :headers, %{})
  end

  defp get_options(opts) do
    Keyword.get(opts, :options, %{})
  end

  defp normalize_url(url) do
    url
    |> String.trim()
    |> String.trim_trailing("/")
    |> ensure_https()
  end

  defp ensure_https(url) do
    if String.starts_with?(url, "http://") or String.starts_with?(url, "https://") do
      url
    else
      "https://#{url}"
    end
  end
end
