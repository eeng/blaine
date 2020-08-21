defmodule WatchLater.Google.AuthAPI do
  @behaviour WatchLater.Google.Behaviours.AuthAPI

  alias WatchLater.Google.AuthToken
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://oauth2.googleapis.com"
  plug Tesla.Middleware.FormUrlencoded
  plug Tesla.Middleware.DecodeJson
  plug Tesla.Middleware.Logger

  defp config(key), do: Application.get_env(:watch_later, __MODULE__)[key]

  def authorize_url(params \\ []) do
    defaults = %{
      client_id: config(:client_id),
      response_type: "code",
      redirect_uri: "urn:ietf:wg:oauth:2.0:oob"
    }

    query = params |> Enum.into(defaults) |> URI.encode_query()
    "https://accounts.google.com/o/oauth2/v2/auth?" <> query
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

    with {:ok, body} <- post("/token", body) |> handle_response() do
      {:ok, AuthToken.from_json(body)}
    end
  end

  def renew_token(%AuthToken{refresh_token: refresh_token}) do
    body = %{
      client_id: config(:client_id),
      client_secret: config(:client_secret),
      refresh_token: refresh_token,
      grant_type: "refresh_token"
    }

    with {:ok, body} <- post("/token", body) |> handle_response() do
      {:ok, AuthToken.from_json(body) |> Map.put(:refresh_token, refresh_token)}
    end
  end

  defp handle_response(response) do
    case response do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, %{body: body}} -> {:error, body}
      error -> error
    end
  end
end
