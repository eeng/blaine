defmodule Blaine.Persistence.Repository.Redis do
  @moduledoc """
  This repository stores the data in a Redis instance.

  Implemented as a GenServer as a way to serialize some requests to Redis
  that need to be atomic (add_account for example).
  """

  use GenServer
  use Blaine.Persistance.Repository

  @ns :blaine
  @me __MODULE__

  def start_link(_opts) do
    GenServer.start_link(@me, :ok, name: @me)
  end

  @impl Repository
  def accounts(role) do
    get_accounts()
    |> Map.values()
    |> Enum.filter(&role_matches?(&1, role))
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
    store(:last_run_at, last_run_at)
  end

  @impl Repository
  def last_run_at() do
    get(:last_run_at)
  end

  @impl GenServer
  def init(:ok) do
    {:ok, NotUsed}
  end

  @impl GenServer
  def handle_call({:add_account, account}, _from, state) do
    new_accounts = get_accounts() |> Map.put(account.id, account)
    {:reply, store(:accounts, new_accounts), state}
  end

  @impl GenServer
  def handle_call({:remove_account, id}, _from, state) do
    new_accounts = get_accounts() |> Map.delete(id)
    {:reply, store(:accounts, new_accounts), state}
  end

  defp store(key, value) do
    value = :erlang.term_to_binary(value)
    {:ok, _} = Redix.command(:redix, ["SET", ns_key(key), value])
    :ok
  end

  defp get(key, default \\ nil) do
    with {:ok, value} when not is_nil(value) <- Redix.command(:redix, ["GET", ns_key(key)]) do
      :erlang.binary_to_term(value)
    else
      _ -> default
    end
  end

  defp get_accounts do
    get(:accounts, %{})
  end

  defp ns_key(key) do
    "#{@ns}.#{key}"
  end
end
