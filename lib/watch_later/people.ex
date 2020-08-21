defmodule WatchLater.People do
  alias WatchLater.AuthToken

  def client(%AuthToken{access_token: access_token, token_type: token_type}) do
    Tesla.client([
      {Tesla.Middleware.BaseUrl, "https://people.googleapis.com/v1"},
      {Tesla.Middleware.Headers, [{"Authorization", "#{token_type} #{access_token}"}]},
      Tesla.Middleware.JSON,
      Tesla.Middleware.Logger
    ])
  end

  # Requires scope https://www.googleapis.com/auth/userinfo.profile
  def me(client, params \\ []) do
    client |> Tesla.get("/people/me", query: params) |> handle_response()
  end

  defp handle_response(response) do
    case response do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, %{body: %{"error" => error}}} -> {:error, error}
      error -> error
    end
  end
end
