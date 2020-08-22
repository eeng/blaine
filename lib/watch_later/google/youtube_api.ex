defmodule WatchLater.Google.YouTubeAPI do
  alias WatchLater.Google.AuthToken

  defp http(), do: Application.get_env(:watch_later, :components)[:http_client]

  defmodule Subscription do
    defstruct [:title, :channel_id]
  end

  def client(%AuthToken{access_token: access_token, token_type: token_type}) do
    http().client(
      base_url: "https://www.googleapis.com/youtube/v3",
      headers: [{"Authorization", "#{token_type} #{access_token}"}]
    )
  end

  # Requires scope https://www.googleapis.com/auth/youtube.readonly
  def list_subscriptions(token, params \\ []) do
    params = Keyword.merge([mine: true, part: "snippet", maxResults: 50], params)

    client(token)
    |> http().get("/subscriptions", query: params)
    |> extract_subscriptions()
  end

  defp extract_subscriptions({:ok, %{"items" => items}}) do
    for %{"snippet" => %{"title" => title, "resourceId" => %{"channelId" => channelId}}} <- items do
      %Subscription{title: title, channel_id: channelId}
    end
  end

  # Google.YouTubeAPI.list_subscriptions(t, mine: true, part: "snippet", maxResults: 2)
  # Google.YouTubeAPI.client(t) |> Util.HTTP.get("/channels", query: [id: "UC_x5XG1OV2P6uZZ5FSM9Ttw", part: "contentDetails"])
  # Google.YouTubeAPI.client(t) |> Util.HTTP.get("/playlistItems", query: [playlistId: "UU_x5XG1OV2P6uZZ5FSM9Ttw", part: "snippet", maxResults: 50])
end
