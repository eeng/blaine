defmodule Persistence.Repository.Dets do
  @moduledoc """
  This GenServer handles the system persistance in a DETS table.
  """

  use Blaine.Persistance.Repository
  use GenServer

  @me __MODULE__

  def start_link(_) do
    GenServer.start_link(@me, :blaine, name: @me)
  end

  @impl Repository
  def accounts(role) do
    GenServer.call(@me, {:get, :accounts, %{}})
    |> Map.values()
    |> Enum.filter(&role_matches?(&1, role))
  end

  @impl Repository
  def save_last_run_at(last_run_at) do
    GenServer.call(@me, {:store, :last_run_at, last_run_at})
  end

  @impl Repository
  def last_run_at() do
    GenServer.call(@me, {:get, :last_run_at, nil})
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
  def handle_call({:get, key, default}, _from, db) do
    reply =
      case :dets.lookup(db, key) do
        [{^key, value}] -> value
        _ -> default
      end

    {:reply, reply, db}
  end
end
