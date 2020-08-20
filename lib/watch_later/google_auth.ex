defmodule WatchLater.GoogleAuth do
  @config Application.get_env(:watch_later, __MODULE__)

  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://oauth2.googleapis.com"
  plug Tesla.Middleware.FormUrlencoded
  plug Tesla.Middleware.DecodeJson
  plug Tesla.Middleware.Logger

  defmodule Token do
    defstruct [:access_token, :expires_in, :refresh_token, :token_type]
  end

  def authorize_url(params \\ []) do
    defaults = %{
      response_type: "code",
      redirect_uri: "urn:ietf:wg:oauth:2.0:oob",
      client_id: @config[:client_id]
    }

    query = params |> Enum.into(defaults) |> URI.encode_query()
    "https://accounts.google.com/o/oauth2/v2/auth?" <> query
  end

  def get_token(code) do
    post_request(%{
      code: code,
      client_id: @config[:client_id],
      client_secret: @config[:client_secret],
      redirect_uri: "urn:ietf:wg:oauth:2.0:oob",
      grant_type: "authorization_code"
    })
  end

  def renew_token(%Token{refresh_token: refresh_token}) do
    token =
      post_request(%{
        client_id: @config[:client_id],
        client_secret: @config[:client_secret],
        refresh_token: refresh_token,
        grant_type: "refresh_token"
      })

    # Re-insert the refresh_token as it doesn't comes back in the response
    with {:ok, token} <- token do
      {:ok, %{token | refresh_token: refresh_token}}
    end
  end

  defp post_request(body) do
    case post("/token", body) do
      {:ok, %{status: 200, body: body}} -> {:ok, to_struct(Token, body)}
      {:ok, %{body: body}} -> {:error, body}
      error -> error
    end
  end

  @doc """
  Creates a struct from a map of strings.
  """
  def to_struct(kind, attrs) do
    struct = struct(kind)

    Enum.reduce(Map.to_list(struct), struct, fn {k, _}, acc ->
      case Map.fetch(attrs, Atom.to_string(k)) do
        {:ok, v} -> %{acc | k => v}
        :error -> acc
      end
    end)
  end
end
