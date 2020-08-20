defmodule WatchLater.GoogleAuth do
  @config Application.get_env(:watch_later, __MODULE__)

  defmodule Token do
    defstruct [:access_token, :expires_in, :refresh_token, :token_type]
    use ExConstructor
  end

  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://oauth2.googleapis.com"
  plug Tesla.Middleware.FormUrlencoded
  plug Tesla.Middleware.DecodeJson
  plug Tesla.Middleware.Logger

  def authorize_url(params \\ []) do
    defaults = %{
      client_id: @config[:client_id],
      response_type: "code",
      redirect_uri: "urn:ietf:wg:oauth:2.0:oob"
    }

    query = params |> Enum.into(defaults) |> URI.encode_query()
    "https://accounts.google.com/o/oauth2/v2/auth?" <> query
  end

  def get_token(code) do
    post("/token", %{
      code: code,
      client_id: @config[:client_id],
      client_secret: @config[:client_secret],
      redirect_uri: "urn:ietf:wg:oauth:2.0:oob",
      grant_type: "authorization_code"
    })
    |> handle_response()
  end

  def renew_token(%Token{refresh_token: refresh_token}) do
    token =
      post("/token", %{
        client_id: @config[:client_id],
        client_secret: @config[:client_secret],
        refresh_token: refresh_token,
        grant_type: "refresh_token"
      })
      |> handle_response()

    # Re-insert the refresh_token as it doesn't comes back in the response
    with {:ok, token} <- token do
      {:ok, %{token | refresh_token: refresh_token}}
    end
  end

  defp handle_response(response) do
    case response do
      {:ok, %{status: 200, body: body}} -> {:ok, Token.new(body)}
      {:ok, %{body: body}} -> {:error, body}
      error -> error
    end
  end
end
