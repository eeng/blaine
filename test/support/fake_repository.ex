defmodule Blaine.FakeRepository do
  use Blaine.Persistance.Repository
  use Agent

  @me __MODULE__

  defmodule State do
    defstruct accounts: %{}, last_run_at: nil
  end

  def start_link(_opts) do
    Agent.start_link(fn -> %State{} end, name: @me)
  end

  @impl true
  def accounts(role) do
    get(:accounts) |> Map.values() |> Enum.filter(&role_matches?(&1, role))
  end

  @impl true
  def add_account(account) do
    Agent.update(@me, fn %{accounts: accounts} = state ->
      new_accounts = accounts |> Map.put(account.id, account)
      %{state | accounts: new_accounts}
    end)
  end

  @impl true
  def remove_account(id) do
    Agent.update(@me, fn %{accounts: accounts} = state ->
      %{state | accounts: accounts |> Map.delete(id)}
    end)
  end

  @impl true
  def last_run_at() do
    get(:last_run_at)
  end

  @impl true
  def save_last_run_at(last_run_at) do
    store(:last_run_at, last_run_at)
  end

  defp store(key, value) do
    Agent.update(@me, &Map.put(&1, key, value))
  end

  defp get(key, default \\ nil) do
    Agent.get(@me, &Map.get(&1, key, default))
  end

  defmacro __using__(_opts) do
    quote do
      alias Blaine.FakeRepository

      setup do
        start_supervised!(FakeRepository)
        :ok
      end
    end
  end
end
