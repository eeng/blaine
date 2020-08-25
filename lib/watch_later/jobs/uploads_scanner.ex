defmodule WatchLater.Jobs.UploadsScanner do
  @moduledoc """
  This process runs periodically to discover new uploads and add them to the WL playlist.
  It keeps the `last_published_after` as a checkpoint, to continue from that point forward
  on every execution.
  """

  use GenServer

  require Logger

  defmodule State do
    defstruct [:run_every_ms, :last_published_after]
  end

  def start_link(opts) do
    name = Keyword.get(opts, :name, __MODULE__)
    run_every_ms = Keyword.get(opts, :run_every_ms, config(:run_every_ms))
    last_published_after = Keyword.get(opts, :last_published_after, DateTime.utc_now())
    state = %State{run_every_ms: run_every_ms, last_published_after: last_published_after}
    GenServer.start_link(__MODULE__, state, name: name)
  end

  @impl true
  def init(state) do
    schedule_work(state)
    {:ok, state}
  end

  @impl true
  def handle_info(:work, %State{last_published_after: last_published_after} = state) do
    Logger.info("Scanning for new uploads published after #{last_published_after} ...")

    {:ok, added_count} =
      uploads_service().find_uploads_and_add_to_watch_later(published_after: last_published_after)

    Logger.info("Done! Videos added: #{added_count}")

    schedule_work(state)
    {:noreply, %{state | last_published_after: DateTime.utc_now()}}
  end

  defp schedule_work(%State{run_every_ms: run_every_ms}) do
    if run_every_ms > 0, do: Process.send_after(self(), :work, run_every_ms)
  end

  defp uploads_service(), do: Application.get_env(:watch_later, :components)[:uploads_service]

  defp config(key), do: Application.get_env(:watch_later, __MODULE__)[key]
end
