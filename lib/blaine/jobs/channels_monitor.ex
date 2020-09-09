defmodule Blaine.Jobs.ChannelsMonitor do
  @moduledoc """
  This process runs periodically to discover new uploads and add them to the WL playlist.
  It keeps the `last_run_at` as a checkpoint, to continue from that point forward
  on every execution.
  """

  use GenServer

  require Logger

  @uploads_service Application.get_env(:blaine, :components)[:uploads_service]
  @repository Application.get_env(:blaine, :components)[:repository]

  defmodule State do
    defstruct [
      # The server will run every :interval minutes.
      :interval,

      # YouTube sometimes has a delay between the published_at time of a video,
      # an the time it appears on the playlistItems endpoint. Hence, on each
      # execution we scan again a previous interval.
      # Otherwise some videos were missed.
      :lookback_span,
      :seen_videos,

      # Each execution will find uploads after :last_run_at - :lookback_span
      :last_run_at
    ]
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    interval = Keyword.get(opts, :interval, 0)
    lookback_span = Keyword.get(opts, :lookback_span, 60)
    last_run_at = @repository.last_run_at() || DateTime.utc_now()

    state = %State{
      interval: interval,
      lookback_span: lookback_span,
      last_run_at: last_run_at,
      seen_videos: MapSet.new()
    }

    if interval > 0 do
      Logger.info(
        "Starting monitor with interval: #{interval} min, " <>
          "looking back: #{lookback_span} min, last_run_at: #{last_run_at}"
      )

      :timer.send_interval(interval * 60 * 1000, :work)
    end

    {:ok, state}
  end

  @impl true
  def handle_info(:work, %State{last_run_at: last_run_at, lookback_span: lookback_span} = state) do
    published_after = last_run_at |> DateTime.add(-lookback_span * 60, :second)
    new_last_run_at = DateTime.utc_now()

    Logger.info(
      "Looking for uploads published after #{published_after}" <>
        " (seen: #{Enum.count(state.seen_videos)}) ..."
    )

    added_ids =
      find_uploads_and_add_to_watch_later(
        published_after: published_after,
        already_seen: state.seen_videos
      )

    Logger.info("Done! Videos added: #{Enum.count(added_ids)}")

    @repository.save_last_run_at(new_last_run_at)
    new_seen_videos = added_ids |> Enum.into(state.seen_videos)

    {:noreply, %{state | last_run_at: new_last_run_at, seen_videos: new_seen_videos}}
  end

  defp find_uploads_and_add_to_watch_later(filters) do
    @uploads_service.find_uploads_and_add_to_watch_later(filters)
    |> Enum.map(fn
      {video, :ok} -> video
      {video, {:error, :already_in_playlist}} -> video
    end)
    |> Enum.map(& &1.id)
  end
end
