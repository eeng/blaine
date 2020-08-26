# TODO move to test/support and rename and maybe use agent?
defmodule Blaine.Storage.Database.ETS do
  @moduledoc """
  This GenServer handles the system persistance in a ETS table. Mainly for test usage.
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

  # TODO rename to purge
  def destroy() do
    GenServer.call(@me, :destroy)
  end

  @impl true
  def init(table) do
    db = :ets.new(table, [:set, :protected])
    {:ok, db}
  end

  @impl true
  def handle_call({:store, key, value}, _from, db) do
    :ets.insert(db, {key, value})
    {:reply, :ok, db}
  end

  @impl true
  def handle_call({:fetch, key}, _from, db) do
    reply =
      case :ets.lookup(db, key) do
        [{^key, value}] -> {:ok, value}
        _ -> {:error, :not_found}
      end

    {:reply, reply, db}
  end

  @impl true
  def handle_call(:destroy, _from, db) do
    :ets.delete_all_objects(db)
    {:reply, :ok, db}
  end
end
