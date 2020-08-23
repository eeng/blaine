defmodule WatchLater.Google.YouTubeAPI do
  alias WatchLater.Google.AuthToken

  defp http(), do: Application.get_env(:watch_later, :components)[:http_client]

  def client(%AuthToken{access_token: access_token, token_type: token_type}) do
    http().client(
      base_url: "https://www.googleapis.com/youtube/v3",
      headers: [{"Authorization", "#{token_type} #{access_token}"}]
    )
  end

  # Requires scope https://www.googleapis.com/auth/youtube.readonly
  @spec my_subscriptions(%AuthToken{}) :: [map]
  def my_subscriptions(token) do
    client(token)
    |> http().get("/subscriptions", query: [mine: true, part: "snippet", maxResults: 50])
    |> extract_subscriptions()
  end

  defp extract_subscriptions({:ok, %{"items" => items}}) do
    response =
      for %{"snippet" => %{"title" => title, "resourceId" => %{"channelId" => channelId}}} <-
            items do
        %{title: title, channel_id: channelId}
      end

    {:ok, response}
  end

  defp extract_subscriptions(response), do: response

  @spec get_uploads_playlist_id(%AuthToken{}, String.t()) :: String.t()
  def get_uploads_playlist_id(token, channel_id) do
    client(token)
    |> http().get("/channels", query: [id: channel_id, part: "contentDetails"])
    |> extract_uploads_playlist_id()
  end

  defp extract_uploads_playlist_id({:ok, %{"items" => items}}) do
    [%{"contentDetails" => %{"relatedPlaylists" => %{"uploads" => playlist_id}}}] = items
    {:ok, playlist_id}
  end

  defp extract_uploads_playlist_id(response), do: response

  # Google.YouTubeAPI.client(t) |> Util.HTTP.get("/playlistItems", query: [playlistId: "UU_x5XG1OV2P6uZZ5FSM9Ttw", part: "snippet", maxResults: 50])
end
