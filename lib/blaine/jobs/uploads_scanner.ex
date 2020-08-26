defmodule Blaine.Jobs.UploadsScanner do
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
    defstruct [:interval, :last_run_at]
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    interval = Keyword.get(opts, :interval, 0) * 1000
    last_run_at = @repository.last_run_at() || DateTime.utc_now()

    state = %State{interval: interval, last_run_at: last_run_at}

    Logger.info("Starting UploadScanner with interval: #{interval}, last_run_at: #{last_run_at}")

    # TODO try :timer.send_interval(1000, :tick)
    schedule_work(state)
    {:ok, state}
  end

  @impl true
  def handle_info(:work, %State{last_run_at: last_run_at} = state) do
    Logger.info("Scanning for new uploads published after #{last_run_at}...")

    {:ok, added_count} =
      @uploads_service.find_uploads_and_add_to_watch_later(published_after: last_run_at)

    Logger.info("Done! Videos added: #{added_count}")

    new_last_run_at = DateTime.utc_now()
    @repository.save_last_run_at(new_last_run_at)

    schedule_work(state)
    {:noreply, %{state | last_run_at: new_last_run_at}}
  end

  defp schedule_work(%State{interval: interval}) do
    if interval > 0, do: Process.send_after(self(), :work, interval)
  end
end
