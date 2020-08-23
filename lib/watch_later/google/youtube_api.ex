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
  @spec my_subscriptions(%AuthToken{}) :: {:ok, [map]} | {:error, any}
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

  @spec get_uploads_playlist_id(%AuthToken{}, String.t()) :: {:ok, String.t()} | {:error, any}
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

  @spec list_videos(%AuthToken{}, String.t()) :: {:ok, String.t()} | {:error, any}
  def list_videos(token, playlist_id) do
    q = [playlistId: playlist_id, part: "snippet,contentDetails", maxResults: 50]

    client(token)
    |> http().get("/playlistItems", query: q)
    |> extract_videos()
  end

  defp extract_videos({:ok, %{"items" => items}}) do
    videos =
      for %{
            "contentDetails" => %{"videoId" => id, "videoPublishedAt" => published_at},
            "snippet" => %{"title" => title}
          } <- items do
        {:ok, published_at, _} = DateTime.from_iso8601(published_at)
        %{id: id, published_at: published_at, title: title}
      end

    {:ok, videos}
  end

  defp extract_videos(response), do: response
end
