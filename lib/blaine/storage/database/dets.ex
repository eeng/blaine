defmodule Blaine.Storage.Database.DETS do
  # TODO see here how to differentiate the @impl https://github.com/quantum-elixir/quantum-storage-persistent-ets/blob/master/lib/quantum_storage_ets.ex
  @moduledoc """
  This GenServer handles the system persistance in a DETS table.
  """
  use GenServer
  use Blaine.Storage.Database

  @me __MODULE__

  def start_link(_) do
    table = Application.get_env(:blaine, @me)[:table]
    GenServer.start_link(@me, table, name: @me)
  end

  @impl true
  def store(key, value) do
    GenServer.call(@me, {:store, key, value})
  end

  @impl true
  def fetch(key) do
    GenServer.call(@me, {:fetch, key})
  end

  @impl true
  def init(table) do
    :dets.open_file(table, [{:file, db_file(table)}])
  end

  @impl true
  def terminate(_reason, db) do
    :dets.close(db)
  end

  @impl true
  def handle_call({:store, key, value}, _from, db) do
    :ok = :dets.insert(db, {key, value})
    {:reply, :ok, db}
  end

  @impl true
  def handle_call({:fetch, key}, _from, db) do
    reply =
      case :dets.lookup(db, key) do
        [{^key, value}] -> {:ok, value}
        _ -> {:error, :not_found}
      end

    {:reply, reply, db}
  end

  defp db_file(db) do
    "#{db}.db" |> String.to_charlist()
  end
end
