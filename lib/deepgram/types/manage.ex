defmodule Deepgram.Types.Manage do
  @moduledoc """
  Types for the Manage (Project and Key Management) service.
  """

  @type project :: %{
          project_id: String.t(),
          name: String.t(),
          company: String.t(),
          org_id: String.t(),
          created: String.t(),
          updated: String.t()
        }

  @type projects_response :: %{
          projects: [project()]
        }

  @type key :: %{
          key_id: String.t(),
          api_key: String.t(),
          comment: String.t(),
          created: String.t(),
          scopes: [String.t()],
          tags: [String.t()]
        }

  @type keys_response :: %{
          api_keys: [key()]
        }

  @type key_response :: %{
          api_key: key()
        }

  @type key_options :: %{
          comment: String.t(),
          scopes: [String.t()],
          tags: [String.t()]
        }

  @type member :: %{
          member_id: String.t(),
          first_name: String.t(),
          last_name: String.t(),
          email: String.t(),
          scopes: [String.t()]
        }

  @type members_response :: %{
          members: [member()]
        }

  @type scope :: %{
          scope: String.t()
        }

  @type scopes_response :: %{
          scopes: [scope()]
        }

  @type scope_options :: %{
          scope: String.t()
        }

  @type invite :: %{
          email: String.t(),
          scope: String.t(),
          created: String.t()
        }

  @type invites_response :: %{
          invites: [invite()]
        }

  @type invite_options :: %{
          email: String.t(),
          scope: String.t()
        }

  @type usage_request :: %{
          request_id: String.t(),
          created: String.t(),
          path: String.t(),
          api_key_id: String.t(),
          response: map(),
          callback: String.t() | nil
        }

  @type usage_requests_response :: %{
          page: integer(),
          limit: integer(),
          requests: [usage_request()]
        }

  @type usage_response :: %{
          start: String.t(),
          end: String.t(),
          usage: map()
        }

  @type balance :: %{
          balance_id: String.t(),
          amount: float(),
          units: String.t(),
          purchased: String.t()
        }

  @type balances_response :: %{
          balances: [balance()]
        }

  @type model :: %{
          name: String.t(),
          canonical_name: String.t(),
          architecture: String.t(),
          languages: [String.t()],
          version: String.t(),
          uuid: String.t(),
          tier: String.t(),
          requests: integer(),
          fallback_to: String.t()
        }

  @type models_response :: %{
          stt: [model()],
          tts: [model()],
          read: [model()]
        }

  @type model_response :: %{
          name: String.t(),
          canonical_name: String.t(),
          architecture: String.t(),
          language: String.t(),
          version: String.t(),
          uuid: String.t(),
          tier: String.t(),
          requests: integer(),
          fallback_to: String.t()
        }

  @type message :: %{
          message: String.t()
        }
end
