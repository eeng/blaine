defmodule WatchLater.Jobs.UploadsScanner do
  @moduledoc """
  This process runs periodically to discover new uploads and add them to the WL playlist.
  It keeps the `last_run_at` as a checkpoint, to continue from that point forward
  on every execution.
  """

  use GenServer

  require Logger
  alias WatchLater.Storage.DB

  defmodule State do
    defstruct [:interval, :last_run_at]
  end

  def start_link(opts) do
    name = Keyword.get(opts, :name, __MODULE__)
    last_run_at = opts[:last_run_at] || DB.get(:last_run_at) || DateTime.utc_now()
    state = %State{interval: config(:interval), last_run_at: last_run_at}
    GenServer.start_link(__MODULE__, state, name: name)
  end

  @impl true
  def init(state) do
    schedule_work(state)
    {:ok, state}
  end

  @impl true
  def handle_info(:work, %State{last_run_at: last_run_at} = state) do
    Logger.info("Scanning for new uploads published after #{last_run_at} ...")

    {:ok, added_count} =
      uploads_service().find_uploads_and_add_to_watch_later(published_after: last_run_at)

    Logger.info("Done! Videos added: #{added_count}")

    new_last_run_at = DateTime.utc_now()
    DB.store(:last_run_at, new_last_run_at)
    schedule_work(state)
    {:noreply, %{state | last_run_at: new_last_run_at}}
  end

  defp schedule_work(%State{interval: interval}) do
    if interval > 0, do: Process.send_after(self(), :work, interval)
  end

  defp uploads_service(), do: Application.get_env(:watch_later, :components)[:uploads_service]

  defp config(key), do: Application.get_env(:watch_later, __MODULE__)[key]
end
