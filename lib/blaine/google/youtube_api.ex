defmodule Blaine.Google.YouTubeAPI.Behaviour do
  alias Blaine.Google.AuthToken

  @callback my_subscriptions(AuthToken.t()) :: {:ok, [map]} | {:error, any}
  @callback get_uploads_playlist_id(AuthToken.t(), String.t()) ::
              {:ok, String.t()} | {:error, any}
  @callback list_videos(AuthToken.t(), String.t()) :: {:ok, String.t()} | {:error, any}
  @callback insert_video(AuthToken.t(), String.t(), String.t()) :: :ok | {:error, any}
end

defmodule Blaine.Google.YouTubeAPI do
  @behaviour Blaine.Google.YouTubeAPI.Behaviour

  alias Blaine.Google.AuthToken

  defp http(), do: Application.get_env(:blaine, :components)[:http_client]

  def client(%AuthToken{access_token: access_token, token_type: token_type}) do
    http().client(
      base_url: "https://www.googleapis.com/youtube/v3",
      headers: [{"Authorization", "#{token_type} #{access_token}"}]
    )
  end

  @impl true
  def my_subscriptions(token) do
    client(token)
    |> get_all_pages("/subscriptions",
      query: [mine: true, part: "snippet", order: "alphabetical", maxResults: 50]
    )
    |> handle_subscriptions_response()
  end

  defp handle_subscriptions_response({:ok, responses}) do
    subscriptions =
      for %{"items" => items} <- responses,
          %{"snippet" => %{"title" => title, "resourceId" => %{"channelId" => channel_id}}} <-
            items do
        %{title: title, channel_id: channel_id}
      end

    {:ok, subscriptions}
  end

  defp handle_subscriptions_response(response), do: response

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
    |> handle_videos_response()
  end

  defp handle_videos_response({:ok, %{"items" => items}}) do
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

  defp handle_videos_response(response), do: response

  @impl true
  def insert_video(token, video_id, playlist_id) do
    body = %{
      snippet: %{
        playlistId: playlist_id,
        resourceId: %{kind: "youtube#video", videoId: video_id}
      }
    }

    client(token)
    |> http().post("/playlistItems", body: body, query: [part: "snippet"])
    |> handle_insert_response()
  end

  defp handle_insert_response({:ok, _}), do: :ok

  defp handle_insert_response({:error, error}) do
    case error do
      %{"error" => %{"errors" => [%{"reason" => "videoAlreadyInPlaylist"}]}} ->
        {:error, :already_in_playlist}

      _ ->
        {:error, error}
    end
  end

  defp get_all_pages(client, url, opts), do: get_all_pages(client, url, opts, [])

  defp get_all_pages(client, url, opts, responses) do
    case http().get(client, url, opts) do
      {:ok, %{"nextPageToken" => next_page} = response} ->
        opts = update_in(opts[:query], &Keyword.put(&1, :pageToken, next_page))
        get_all_pages(client, url, opts, [response | responses])

      {:ok, response} ->
        {:ok, [response | responses] |> Enum.reverse()}

      result ->
        result
    end
  end
end
