defmodule Persistence.Repository.Dets do
  @moduledoc """
  This GenServer handles the system persistance in a DETS table.
  """

  use Blaine.Persistance.Repository
  use GenServer

  @me __MODULE__

  def start_link(opts) do
    table = Keyword.get(opts, :table, :blaine)
    GenServer.start_link(@me, table, name: @me)
  end

  @impl Repository
  def accounts(role) do
    GenServer.call(@me, {:accounts, role})
  end

  @impl Repository
  def add_account(account) do
    GenServer.call(@me, {:add_account, account})
  end

  @impl Repository
  def remove_account(id) do
    GenServer.call(@me, {:remove_account, id})
  end

  @impl Repository
  def save_last_run_at(last_run_at) do
    GenServer.call(@me, {:save_last_run_at, last_run_at})
  end

  @impl Repository
  def last_run_at() do
    GenServer.call(@me, :last_run_at)
  end

  @impl GenServer
  def init(table) do
    File.mkdir("priv")
    path = "priv/#{table}.db" |> String.to_charlist()
    :dets.open_file(table, [{:file, path}])
    {:ok, table}
  end

  @impl GenServer
  def terminate(_reason, table) do
    :dets.close(table)
  end

  @impl GenServer
  def handle_call({:accounts, role}, _from, table) do
    accounts =
      get_accounts(table)
      |> Map.values()
      |> Enum.filter(&role_matches?(&1, role))

    {:reply, accounts, table}
  end

  @impl GenServer
  def handle_call({:add_account, account}, _from, table) do
    new_accounts = get_accounts(table) |> Map.put(account.id, account)
    {:reply, store(table, :accounts, new_accounts), table}
  end

  @impl GenServer
  def handle_call({:remove_account, id}, _from, table) do
    new_accounts = get_accounts(table) |> Map.delete(id)
    {:reply, store(table, :accounts, new_accounts), table}
  end

  @impl GenServer
  def handle_call({:save_last_run_at, last_run_at}, _from, table) do
    {:reply, store(table, :last_run_at, last_run_at), table}
  end

  @impl GenServer
  def handle_call(:last_run_at, _from, table) do
    {:reply, get(table, :last_run_at), table}
  end

  defp store(table, key, value) do
    :dets.insert(table, {key, value})
  end

  defp get(table, key, default \\ nil) do
    case :dets.lookup(table, key) do
      [{^key, value}] -> value
      _ -> default
    end
  end

  defp get_accounts(table) do
    get(table, :accounts, %{})
  end
end
