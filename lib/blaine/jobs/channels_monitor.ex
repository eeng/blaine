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
    defstruct [:interval, :last_run_at, :seen_videos]
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    interval = Keyword.get(opts, :interval, 0) * 1000
    last_run_at = @repository.last_run_at() || DateTime.utc_now()
    state = %State{interval: interval, last_run_at: last_run_at, seen_videos: MapSet.new()}

    if interval > 0 do
      Logger.info("Monitoring with interval: #{interval}, last_run_at: #{last_run_at}")
      :timer.send_interval(interval, :work)
    end

    {:ok, state}
  end

  @impl true
  def handle_info(:work, %State{last_run_at: last_run_at, seen_videos: seen_videos} = state) do
    Logger.info("Looking for uploads published after #{last_run_at}...")
    new_last_run_at = DateTime.utc_now()

    added_ids = find_uploads_and_add_to_watch_later(published_after: last_run_at)

    @repository.save_last_run_at(new_last_run_at)
    new_seen_videos = added_ids |> Enum.into(seen_videos)

    Logger.info(fn ->
      "Done! Videos added: #{Enum.count(added_ids)}. Seen: #{Enum.count(new_seen_videos)}"
    end)

    {:noreply, %{state | last_run_at: new_last_run_at, seen_videos: new_seen_videos}}
  end

  defp find_uploads_and_add_to_watch_later(opts) do
    @uploads_service.find_uploads_and_add_to_watch_later(opts)
    |> Enum.map(fn
      {video, :ok} -> video
      {video, {:error, :already_in_playlist}} -> video
    end)
    |> Enum.map(& &1.id)
  end
end
