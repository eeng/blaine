defmodule Blaine.Jobs.UploadsScanner do
  @moduledoc """
  This process runs periodically to discover new uploads and add them to the WL playlist.
  It keeps the `last_run_at` as a checkpoint, to continue from that point forward
  on every execution.
  """

  use GenServer

  require Logger

  defmodule State do
    defstruct [:interval, :last_run_at, :repository, :service]
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    interval = Keyword.get(opts, :interval, 0) * 1000
    repository = Keyword.fetch!(opts, :repository)
    last_run_at = repository.last_run_at() || DateTime.utc_now()

    state = %State{
      interval: interval,
      last_run_at: last_run_at,
      repository: repository,
      service: Keyword.fetch!(opts, :service)
    }

    Logger.info("Starting UploadScanner with interval: #{interval}, last_run_at: #{last_run_at}")

    # TODO try :timer.send_interval(1000, :tick)
    schedule_work(state)
    {:ok, state}
  end

  @impl true
  def handle_info(:work, state) do
    %State{last_run_at: last_run_at, repository: repository, service: service} = state
    Logger.info("Scanning for new uploads published after #{last_run_at}...")

    {:ok, added_count} = service.find_uploads_and_add_to_watch_later(published_after: last_run_at)

    Logger.info("Done! Videos added: #{added_count}")

    new_last_run_at = DateTime.utc_now()
    repository.save_last_run_at(new_last_run_at)

    schedule_work(state)
    {:noreply, %{state | last_run_at: new_last_run_at}}
  end

  defp schedule_work(%State{interval: interval}) do
    if interval > 0, do: Process.send_after(self(), :work, interval)
  end
end
