defmodule WatchLater.Services.UploadsScanner do
  @moduledoc """
  This module is responsible for retrieving the latest uploads through the YouTube API.
  """
  alias WatchLater.Entities.{Video, Channel, Account}

  defp accounts_manager(), do: Application.get_env(:watch_later, :components)[:accounts_manager]
  defp youtube_api(), do: Application.get_env(:watch_later, :components)[:google_youtube_api]

  def find_uploads(opts) do
    accounts_manager().accounts(:provider)
    |> Enum.flat_map(&find_uploads_for_account(&1, opts))
  end

  def find_uploads_for_account(%Account{auth_token: token}, opts \\ []) do
    with {:ok, subs} <- youtube_api().my_subscriptions(token) do
      subs
      |> Task.async_stream(&find_uploads_for_channel(token, &1))
      |> Enum.flat_map(fn {:ok, videos} -> videos end)
      |> filter_and_sort_videos(opts)
    end
  end

  def find_uploads_for_channel(token, %{channel_id: channel_id} = sub) do
    {:ok, playlist_id} = youtube_api().get_uploads_playlist_id(token, channel_id)
    {:ok, videos} = youtube_api().list_videos(token, playlist_id)
    videos |> Enum.map(&to_video(&1, sub))
  end

  defp to_video(%{video_id: id} = fields, %{title: channel_name, channel_id: channel_id}) do
    struct(Video, fields)
    |> Map.put(:id, id)
    |> Map.put(:channel, %Channel{name: channel_name, id: channel_id})
  end

  def filter_and_sort_videos(videos, opts) do
    videos = videos |> Enum.sort_by(& &1.published_at, DateTime)
    Enum.reduce(opts, videos, &filter_by/2)
  end

  defp filter_by({:published_after, published_after}, videos) do
    videos
    |> Enum.filter(fn %{published_at: published_at} ->
      DateTime.compare(published_at, published_after) == :gt
    end)
  end

  def add_videos_to_playlist(videos, playlist \\ "WL") do
    added_videos =
      accounts_manager().accounts(:watcher)
      |> Enum.flat_map(&add_videos_to_playlist_of_account(&1, videos, playlist))
      |> Enum.sum()

    {:ok, added_videos}
  end

  defp add_videos_to_playlist_of_account(%Account{auth_token: token}, videos, playlist) do
    videos
    |> Task.async_stream(fn %Video{id: id} ->
      case youtube_api().insert_video(token, id, playlist) do
        :ok -> 1
        _ -> 0
      end
    end)
    |> Enum.into([], fn {:ok, count} -> count end)
  end

  def find_uploads_and_add_to_watch_later(opts) do
    find_uploads(opts) |> add_videos_to_playlist()
  end
end
