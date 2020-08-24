defmodule WatchLater.Services.UploadsScanner do
  @moduledoc """
  This module is responsible for retrieving the latest uploads through the YouTube API.
  """
  alias WatchLater.Entities.{Video, Channel, Account}

  defp accounts_manager(), do: Application.get_env(:watch_later, :components)[:accounts_manager]
  defp youtube_api(), do: Application.get_env(:watch_later, :components)[:google_youtube_api]

  @doc """
  For all provider accounts, it queries the YouTube API to find the latest uploads.

  Supported options:
    * `:published_after` - Return only videos published after this DateTime.
    * `:channel_ids` - Search only for videos of these channels.
  """
  def find_uploads(opts) do
    accounts_manager().accounts(:provider)
    |> Enum.flat_map(&find_uploads_for_account(&1, opts))
  end

  def find_uploads_for_account(%Account{auth_token: token}, opts \\ []) do
    max_concurrency = Keyword.get(opts, :max_concurrency, System.schedulers_online() * 2)

    with {:ok, subs} <- youtube_api().my_subscriptions(token) do
      subs
      |> Enum.map(&to_channel/1)
      |> Channel.filter_channels(opts)
      |> Task.async_stream(&find_uploads_for_channel(token, &1), max_concurrency: max_concurrency)
      |> Enum.flat_map(fn {:ok, videos} -> videos end)
      |> Video.filter_and_sort(opts)
    end
  end

  defp to_channel(%{channel_id: channel_id, title: channel_name}) do
    %Channel{id: channel_id, name: channel_name}
  end

  def find_uploads_for_channel(token, %Channel{id: channel_id} = channel) do
    {:ok, playlist_id} = youtube_api().get_uploads_playlist_id(token, channel_id)
    {:ok, videos} = youtube_api().list_videos(token, playlist_id)
    videos |> Enum.map(&to_video(&1, %{channel | playlist_id: playlist_id}))
  end

  defp to_video(%{video_id: id} = fields, channel) do
    struct(Video, fields)
    |> Map.put(:id, id)
    |> Map.put(:channel, channel)
  end

  def add_videos_to_playlist(videos, opts \\ []) do
    added_videos =
      accounts_manager().accounts(:watcher)
      |> Enum.flat_map(&add_videos_to_playlist_of_account(&1, videos, opts))
      |> Enum.sum()

    {:ok, added_videos}
  end

  defp add_videos_to_playlist_of_account(%Account{auth_token: token}, videos, opts) do
    playlist = Keyword.get(opts, :playlist, "WL")
    max_concurrency = Keyword.get(opts, :max_concurrency, System.schedulers_online() * 2)

    videos
    |> Task.async_stream(
      fn %Video{id: id} ->
        case youtube_api().insert_video(token, id, playlist) do
          :ok -> 1
          _ -> 0
        end
      end,
      max_concurrency: max_concurrency
    )
    |> Enum.into([], fn {:ok, count} -> count end)
  end

  def find_uploads_and_add_to_watch_later(opts) do
    find_uploads(opts) |> add_videos_to_playlist(opts)
  end
end
