defmodule Deepgram.Error do
  @moduledoc """
  Error handling for the Deepgram SDK.

  This module defines various error types that can be raised by the SDK.
  """

  defmodule DeepgramError do
    @moduledoc """
    Base error for all Deepgram SDK errors.
    """
    defexception [:message, :reason]

    @type t :: %__MODULE__{
            message: String.t(),
            reason: any()
          }

    def new(message, reason \\ nil) do
      %__MODULE__{message: message, reason: reason}
    end
  end

  defmodule AuthenticationError do
    @moduledoc """
    Error raised when authentication fails.
    """
    defexception [:message]

    @type t :: %__MODULE__{
            message: String.t()
          }

    def exception(message) when is_binary(message) do
      %__MODULE__{message: message}
    end
  end

  defmodule ApiError do
    @moduledoc """
    Error raised when API requests fail.
    """
    defexception [:message, :status_code, :response_body]

    @type t :: %__MODULE__{
            message: String.t(),
            status_code: integer() | nil,
            response_body: String.t() | nil
          }

    def new(message, status_code \\ nil, response_body \\ nil) do
      %__MODULE__{
        message: message,
        status_code: status_code,
        response_body: response_body
      }
    end
  end

  defmodule TypeError do
    @moduledoc """
    Error raised when there are issues with types or arguments.
    """
    defexception [:message, :expected, :actual]

    @type t :: %__MODULE__{
            message: String.t(),
            expected: String.t() | nil,
            actual: String.t() | nil
          }

    def new(message, expected \\ nil, actual \\ nil) do
      %__MODULE__{
        message: message,
        expected: expected,
        actual: actual
      }
    end
  end

  defmodule HttpError do
    @moduledoc """
    Error raised when HTTP requests fail.
    """
    defexception [:message, :reason]

    @type t :: %__MODULE__{
            message: String.t(),
            reason: any()
          }

    def new(message, reason \\ nil) do
      %__MODULE__{
        message: message,
        reason: reason
      }
    end
  end

  defmodule WebSocketError do
    @moduledoc """
    Error raised when WebSocket connections fail.
    """
    defexception [:message, :reason]

    @type t :: %__MODULE__{
            message: String.t(),
            reason: any()
          }

    def new(message, reason \\ nil) do
      %__MODULE__{
        message: message,
        reason: reason
      }
    end
  end

  defmodule JsonError do
    @moduledoc """
    Error raised when JSON parsing fails.
    """
    defexception [:message, :data]

    @type t :: %__MODULE__{
            message: String.t(),
            data: any()
          }

    def new(message, data \\ nil) do
      %__MODULE__{
        message: message,
        data: data
      }
    end
  end

  defmodule ConfigError do
    @moduledoc """
    Error raised when configuration is invalid.
    """
    defexception [:message, :key]

    @type t :: %__MODULE__{
            message: String.t(),
            key: atom() | nil
          }

    def new(message, key \\ nil) do
      %__MODULE__{
        message: message,
        key: key
      }
    end
  end

  defmodule TimeoutError do
    @moduledoc """
    Error raised when timeout occurs.
    """
    defexception [:message, :timeout]

    @type t :: %__MODULE__{
            message: String.t(),
            timeout: integer() | nil
          }

    def new(message, timeout \\ nil) do
      %__MODULE__{
        message: message,
        timeout: timeout
      }
    end
  end

  # Helper functions for creating common errors

  @doc """
  Creates an authentication error.
  """
  @spec authentication_error(String.t()) :: AuthenticationError.t()
  def authentication_error(message) do
    AuthenticationError.exception(message)
  end

  @doc """
  Creates an API error from an HTTP response.
  """
  @spec api_error(String.t(), integer(), String.t()) :: ApiError.t()
  def api_error(message, status_code, response_body) do
    ApiError.new(message, status_code, response_body)
  end

  @doc """
  Creates a type error.
  """
  @spec type_error(String.t(), String.t(), String.t()) :: TypeError.t()
  def type_error(message, expected, actual) do
    TypeError.new(message, expected, actual)
  end

  @doc """
  Creates an HTTP error.
  """
  @spec http_error(String.t(), any()) :: HttpError.t()
  def http_error(message, reason) do
    HttpError.new(message, reason)
  end

  @doc """
  Creates a WebSocket error.
  """
  @spec websocket_error(String.t(), any()) :: WebSocketError.t()
  def websocket_error(message, reason) do
    WebSocketError.new(message, reason)
  end

  @doc """
  Creates a JSON parsing error.
  """
  @spec json_error(String.t(), any()) :: JsonError.t()
  def json_error(message, data) do
    JsonError.new(message, data)
  end

  @doc """
  Creates a configuration error.
  """
  @spec config_error(String.t(), atom()) :: ConfigError.t()
  def config_error(message, key) do
    ConfigError.new(message, key)
  end

  @doc """
  Creates a timeout error.
  """
  @spec timeout_error(String.t(), integer()) :: TimeoutError.t()
  def timeout_error(message, timeout) do
    TimeoutError.new(message, timeout)
  end
end
