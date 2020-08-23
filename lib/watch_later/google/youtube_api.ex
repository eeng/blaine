defmodule WatchLater.Google.YouTubeAPI.Behaviour do
  alias WatchLater.Google.AuthToken

  @callback my_subscriptions(AuthToken.t()) :: {:ok, [map]} | {:error, any}
  @callback get_uploads_playlist_id(AuthToken.t(), String.t()) ::
              {:ok, String.t()} | {:error, any}
  @callback list_videos(AuthToken.t(), String.t()) :: {:ok, String.t()} | {:error, any}
end

defmodule WatchLater.Google.YouTubeAPI do
  @behaviour WatchLater.Google.YouTubeAPI.Behaviour

  alias WatchLater.Google.AuthToken

  defp http(), do: Application.get_env(:watch_later, :components)[:http_client]

  def client(%AuthToken{access_token: access_token, token_type: token_type}) do
    http().client(
      base_url: "https://www.googleapis.com/youtube/v3",
      headers: [{"Authorization", "#{token_type} #{access_token}"}]
    )
  end

  @impl true
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

  @impl true
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

  @impl true
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
        %{video_id: id, published_at: published_at, title: title}
      end

    {:ok, videos}
  end

  defp extract_videos(response), do: response
end
