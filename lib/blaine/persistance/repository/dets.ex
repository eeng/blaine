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
  def last_run_at() do
    GenServer.call(@me, :last_run_at)
  end

  @impl Repository
  def save_last_run_at(last_run_at) do
    GenServer.call(@me, {:save_last_run_at, last_run_at})
  end

  @impl GenServer
  def init(table) do
    :dets.open_file(table, [{:file, db_file(table)}])
  end

  @impl GenServer
  def terminate(_reason, table) do
    :dets.close(table)
  end

  @impl GenServer
  def handle_call({:save_last_run_at, last_run_at}, _from, table) do
    :ok = :dets.insert(table, {:last_run_at, last_run_at})
    {:reply, :ok, table}
  end

  @impl GenServer
  def handle_call(:last_run_at, _from, table) do
    reply =
      case :dets.lookup(table, :last_run_at) do
        [{:last_run_at, value}] -> value
        _ -> nil
      end

    {:reply, reply, table}
  end

  defp db_file(table) do
    "#{table}.db" |> String.to_charlist()
  end
end
