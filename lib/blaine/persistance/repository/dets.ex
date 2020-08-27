defmodule Persistence.Repository.Dets do
  @moduledoc """
  This GenServer handles the system persistance in a DETS table.
  """

  @behaviour Blaine.Persistance.Repository
  @me __MODULE__

  use GenServer

  alias Blaine.Persistance.Repository

  def start_link(_) do
    GenServer.start_link(@me, :blaine, name: @me)
  end

  @impl Repository
  def save_last_run_at(last_run_at) do
    GenServer.call(@me, {:store, :last_run_at, last_run_at})
  end

  @impl Repository
  def last_run_at() do
    GenServer.call(@me, {:get, :last_run_at})
  end

  @impl GenServer
  def init(table) do
    File.mkdir("priv")
    path = "priv/#{table}.db" |> String.to_charlist()
    :dets.open_file(table, [{:file, path}])
  end

  @impl GenServer
  def terminate(_reason, table) do
    :dets.close(table)
  end

  @impl GenServer
  def handle_call({:store, key, value}, _from, db) do
    :ok = :dets.insert(db, {key, value})
    {:reply, :ok, db}
  end

  @impl GenServer
  def handle_call({:get, key}, _from, db) do
    reply =
      case :dets.lookup(db, key) do
        [{^key, value}] -> value
        _ -> nil
      end

    {:reply, reply, db}
  end
end
