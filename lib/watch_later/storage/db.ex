defmodule WatchLater.Storage.DB do
  @moduledoc """
  This GenServer handles the system persistance in a DETS table.
  """
  use GenServer

  @me __MODULE__

  @dets_table Application.get_env(:watch_later, @me)[:dets_table]

  def start_link(_) do
    GenServer.start_link(@me, :ok, name: @me)
  end

  @spec store(atom, any) :: :ok | {:error, any}
  def store(key, value) do
    GenServer.call(@me, {:store, key, value})
  end

  @spec fetch(atom) :: {:ok, any} | {:error, any}
  def fetch(key) do
    GenServer.call(@me, {:fetch, key})
  end

  @spec get(atom) :: any
  def get(key) do
    case fetch(key) do
      {:ok, value} -> value
      _ -> nil
    end
  end

  @spec destroy() :: :ok | {:error, any}
  def destroy() do
    GenServer.call(@me, :destroy)
  end

  @impl true
  def init(:ok) do
    :dets.open_file(@dets_table, [{:file, db_file(@dets_table)}])
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

  @impl true
  def handle_call(:destroy, _from, db) do
    :dets.delete_all_objects(db)
    File.rm(db_file(db))
    {:reply, :ok, db}
  end

  defp db_file(db) do
    "#{db}.db" |> String.to_charlist()
  end
end
