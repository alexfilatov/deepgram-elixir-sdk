defmodule Deepgram.Client do
  @moduledoc """
  Main client for interacting with the Deepgram API.

  This module provides the main client interface and delegates to specific
  service modules for different API endpoints.
  """

  alias Deepgram.Config

  @type t :: %__MODULE__{
          config: Config.t(),
          listen: module(),
          speak: module(),
          read: module(),
          agent: module(),
          manage: module()
        }

  @enforce_keys [:config]
  defstruct [
    :config,
    listen: Deepgram.Listen,
    speak: Deepgram.Speak,
    read: Deepgram.Read,
    agent: Deepgram.Agent,
    manage: Deepgram.Manage
  ]

  @doc """
  Creates a new Deepgram client.

  ## Parameters

  - `config` - A `Deepgram.Config` struct containing configuration options.

  ## Examples

      iex> config = Deepgram.Config.new(api_key: "your-api-key")
      iex> client = Deepgram.Client.new(config)
      %Deepgram.Client{...}

  """
  @spec new(Config.t()) :: t()
  def new(%Config{} = config) do
    %__MODULE__{
      config: config
    }
  end

  @doc """
  Returns the configuration for the client.
  """
  @spec config(t()) :: Config.t()
  def config(%__MODULE__{config: config}), do: config

  @doc """
  Returns the Listen service module for speech-to-text operations.
  """
  @spec listen(t()) :: module()
  def listen(%__MODULE__{listen: listen}), do: listen

  @doc """
  Returns the Speak service module for text-to-speech operations.
  """
  @spec speak(t()) :: module()
  def speak(%__MODULE__{speak: speak}), do: speak

  @doc """
  Returns the Read service module for text intelligence operations.
  """
  @spec read(t()) :: module()
  def read(%__MODULE__{read: read}), do: read

  @doc """
  Returns the Agent service module for AI agent operations.
  """
  @spec agent(t()) :: module()
  def agent(%__MODULE__{agent: agent}), do: agent

  @doc """
  Returns the Manage service module for project and key management.
  """
  @spec manage(t()) :: module()
  def manage(%__MODULE__{manage: manage}), do: manage
end
