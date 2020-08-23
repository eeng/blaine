defmodule WatchLater.Google.AuthAPI do
  @behaviour WatchLater.Google.Behaviours.AuthAPI

  alias WatchLater.Google.AuthToken

  defp config(key), do: Application.get_env(:watch_later, __MODULE__)[key]
  defp http(), do: Application.get_env(:watch_later, :components)[:http_client]

  def authorize_url(params) do
    defaults = %{
      client_id: config(:client_id),
      response_type: "code",
      redirect_uri: "urn:ietf:wg:oauth:2.0:oob"
    }

    query = params |> Enum.into(defaults) |> URI.encode_query()
    "https://accounts.google.com/o/oauth2/v2/auth?" <> query
  end

  defp client() do
    http().client(
      base_url: "https://oauth2.googleapis.com",
      format: :form_request_json_response
    )
  end

  @impl true
  def get_token(code) do
    body = %{
      code: code,
      client_id: config(:client_id),
      client_secret: config(:client_secret),
      redirect_uri: "urn:ietf:wg:oauth:2.0:oob",
      grant_type: "authorization_code"
    }

    with {:ok, body} <- http().post(client(), "/token", body: body) do
      {:ok, AuthToken.from_json(body)}
    end
  end

  @impl true
  def renew_token(%AuthToken{refresh_token: refresh_token} = token) do
    if AuthToken.must_renew?(token) do
      body = %{
        client_id: config(:client_id),
        client_secret: config(:client_secret),
        refresh_token: refresh_token,
        grant_type: "refresh_token"
      }

      with {:ok, body} <- http().post(client(), "/token", body: body) do
        {:ok, AuthToken.from_json(body) |> Map.put(:refresh_token, refresh_token)}
      end
    else
      :still_valid
    end
  end
end
