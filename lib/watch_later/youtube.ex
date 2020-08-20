defmodule WatchLater.YouTube do
  alias WatchLater.AuthToken

  def client(%AuthToken{access_token: access_token, token_type: token_type}) do
    Tesla.client([
      {Tesla.Middleware.BaseUrl, "https://www.googleapis.com/youtube/v3"},
      {Tesla.Middleware.Headers, [{"Authorization", "#{token_type} #{access_token}"}]},
      Tesla.Middleware.JSON,
      Tesla.Middleware.Logger
    ])
  end

  def list_subscriptions(client, params \\ []) do
    client |> Tesla.get("/subscriptions", query: params) |> handle_response()
  end

  defp handle_response(response) do
    case response do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, %{body: %{"error" => error}}} -> {:error, error}
      error -> error
    end
  end
end
