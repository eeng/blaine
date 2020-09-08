defmodule Blaine.Services.UploadsService.Behaviour do
  alias Blaine.Entities.Video

  @type result :: :ok | {:error, any}
  @callback find_uploads_and_add_to_watch_later(list) :: [{%Video{}, result}]
end

defmodule Blaine.Services.UploadsService do
  @moduledoc """
  This module is responsible for retrieving the latest uploads through the YouTube API.
  """

  @behaviour Blaine.Services.UploadsService.Behaviour

  @accounts_manager Application.get_env(:blaine, :components)[:accounts_manager]
  @youtube_api Application.get_env(:blaine, :components)[:google_youtube_api]

  require Logger
  alias Blaine.Entities.{Video, Channel, Account}

  @doc """
  For all provider accounts, it queries the YouTube API to find the latest uploads.

  Supported options:
    * `:published_after` - Return only videos published after this DateTime.
    * `:channel_ids` - Search only for videos of these channels.
  """
  def find_uploads(opts) do
    @accounts_manager.accounts(:provider)
    |> Enum.flat_map(&find_uploads_for_account(&1, opts))
  end

  def find_uploads_for_account(%Account{auth_token: token} = account, opts \\ []) do
    {max_concurrency, opts} = Keyword.pop(opts, :max_concurrency, System.schedulers_online() * 2)

    {:ok, subs} = @youtube_api.my_subscriptions(token)

    subs
    |> Enum.map(&to_channel/1)
    |> Channel.filter(opts)
    |> log_account_channels(account)
    |> Task.async_stream(&find_uploads_for_channel(token, &1, opts),
      max_concurrency: max_concurrency
    )
    |> Enum.flat_map(fn {:ok, videos} -> videos end)
  end

  defp to_channel(%{channel_id: channel_id, title: channel_name}) do
    %Channel{id: channel_id, name: channel_name}
  end

  def find_uploads_for_channel(token, %Channel{id: channel_id} = channel, opts) do
    {:ok, playlist_id} = @youtube_api.get_uploads_playlist_id(token, channel_id)
    {:ok, videos} = @youtube_api.list_videos(token, playlist_id)

    videos
    |> Enum.map(&to_video(&1, %{channel | playlist_id: playlist_id}))
    |> Video.filter(opts)
    |> log_found_videos(channel)
  end

  defp log_account_channels(channels, %Account{name: account_name}) do
    Logger.info(fn ->
      "Searching latest uploads for account #{account_name} (#{Enum.count(channels)} channels)..."
    end)

    channels
  end

  defp log_found_videos(videos, %Channel{name: name}) do
    Logger.info("New videos in channel #{name}: #{Enum.count(videos)}")
    videos
  end

  defp to_video(%{video_id: id} = fields, channel) do
    struct(Video, fields)
    |> Map.put(:id, id)
    |> Map.put(:channel, channel)
  end

  @doc """
  Uses the YouTube API to insert the videos to the specified playlist (default to WL).
  Returns the added videos.
  """
  def add_videos_to_playlist(videos, opts \\ []) do
    @accounts_manager.accounts(:watcher)
    |> Enum.flat_map(&add_videos_to_playlist_of_account(&1, videos, opts))
  end

  defp add_videos_to_playlist_of_account(%Account{auth_token: token}, videos, opts) do
    playlist = Keyword.get(opts, :playlist, "WL")
    videos |> Enum.map(&add_video_to_playlist(&1, playlist, token))
  end

  defp add_video_to_playlist(video, playlist, token) do
    %Video{id: id, title: title, channel: %{name: channel_name}} = video
    Logger.info("#{channel_name} has uploaded a new video: #{title}")
    result = @youtube_api.insert_video(token, id, playlist)
    {video, result}
  end

  @impl true
  def find_uploads_and_add_to_watch_later(opts) do
    find_uploads(opts) |> add_videos_to_playlist(opts)
  end
end
