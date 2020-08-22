defmodule WatchLater.Google.YouTubeAPI do
  alias WatchLater.Google.AuthToken
  alias WatchLater.Util.HTTP

  def client(%AuthToken{access_token: access_token, token_type: token_type}) do
    HTTP.client(
      base_url: "https://www.googleapis.com/youtube/v3",
      headers: [{"Authorization", "#{token_type} #{access_token}"}]
    )
  end

  # Requires scope https://www.googleapis.com/auth/youtube.readonly
  def list_subscriptions(token, params) do
    client(token) |> HTTP.get("/subscriptions", query: params)
  end
end
