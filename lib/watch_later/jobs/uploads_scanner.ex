defmodule WatchLater.Jobs.UploadsScanner do
  @moduledoc """
  This process runs periodically to discover new uploads and add them to the WL playlist.
  It keeps the `last_published_after` as a checkpoint, to continue from that point forward
  on every execution.
  """

  use GenServer

  defmodule State do
    defstruct [:run_every, :last_published_after]
  end

  def start_link(opts) do
    name = Keyword.get(opts, :name, __MODULE__)
    run_every = Keyword.get(opts, :run_every, 60 * 60 * 1000)
    last_published_after = Keyword.get(opts, :last_published_after, DateTime.utc_now())
    state = %State{run_every: run_every, last_published_after: last_published_after}
    GenServer.start_link(__MODULE__, state, name: name)
  end

  @impl true
  def init(state) do
    schedule_work(state)
    {:ok, state}
  end

  @impl true
  def handle_info(:work, %State{last_published_after: last_published_after} = state) do
    {:ok, _} =
      uploads_service().find_uploads_and_add_to_watch_later(published_after: last_published_after)

    schedule_work(state)
    {:noreply, %{state | last_published_after: DateTime.utc_now()}}
  end

  defp schedule_work(%State{run_every: run_every}) do
    Process.send_after(self(), :work, run_every)
  end

  defp uploads_service(), do: Application.get_env(:watch_later, :components)[:uploads_service]
end
