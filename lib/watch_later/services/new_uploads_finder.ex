defmodule WatchLater.Services.NewUploadsFinder do
  alias WatchLater.Entities.Video

  defp accounts_manager(), do: Application.get_env(:watch_later, :components)[:accounts_manager]
  defp youtube_api(), do: Application.get_env(:watch_later, :components)[:google_youtube_api]

  def find_new_uploads(opts \\ []) do
    Keyword.get(opts, :accounts, accounts_manager().accounts(:provider))
    |> Enum.flat_map(&find_new_uploads_for_account(&1, opts))
  end

  def find_new_uploads_for_account(%{auth_token: token}, _opts \\ []) do
    with {:ok, subs} <- youtube_api().my_subscriptions(token) do
      subs
      |> Enum.flat_map(&find_new_uploads_for_channel(token, &1))
      |> Enum.sort_by(& &1.published_at, {:desc, DateTime})
    end
  end

  def find_new_uploads_for_channel(token, %{channel_id: channel_id}) do
    {:ok, playlist_id} = youtube_api().get_uploads_playlist_id(token, channel_id)
    {:ok, videos} = youtube_api().list_videos(token, playlist_id)
    videos |> Enum.map(&to_video/1)
  end

  defp to_video(%{video_id: id} = fields) do
    struct(Video, fields) |> Map.put(:id, id)
  end
end
