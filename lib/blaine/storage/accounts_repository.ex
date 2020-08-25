defmodule Blaine.Storage.AccountsRepository.Behaviour do
  @callback add_account(any, Account.t()) :: :ok
  @callback remove_account(any, String.t()) :: :ok
  @callback accounts(any, Account.role()) :: [Account.t()]
end

defmodule Blaine.Storage.AccountsRepository do
  @moduledoc """
  This GenServer is in charge of storing the Google accounts.
  """

  @behaviour Blaine.Storage.AccountsRepository.Behaviour
  use GenServer

  alias Blaine.Entities.Account

  @me __MODULE__

  def start_link(opts) do
    name = Keyword.get(opts, :name, @me)
    GenServer.start_link(@me, :ok, name: name)
  end

  @impl true
  def add_account(server, account) do
    GenServer.call(server, {:add_account, account})
  end

  @impl true
  def remove_account(server, id) do
    GenServer.call(server, {:remove_account, id})
  end

  @impl true
  def accounts(server, role \\ :both) do
    GenServer.call(server, {:get_accounts, role})
  end

  @impl true
  def init(_) do
    accounts =
      case db().fetch(:accounts) do
        {:ok, accounts} -> accounts
        _ -> %{}
      end

    {:ok, accounts}
  end

  @impl true
  def handle_call({:add_account, account}, _from, accounts) do
    new_accounts = accounts |> Map.put(account.id, account)
    :ok = db().store(:accounts, new_accounts)
    {:reply, :ok, new_accounts}
  end

  @impl true
  def handle_call({:remove_account, id}, _from, accounts) do
    new_accounts = accounts |> Map.delete(id)
    :ok = db().store(:accounts, new_accounts)
    {:reply, :ok, new_accounts}
  end

  @impl true
  def handle_call({:get_accounts, role}, _from, accounts) do
    filtered = accounts |> Map.values() |> Enum.filter(&role_matches?(&1, role))
    {:reply, filtered, accounts}
  end

  defp role_matches?(_, :both), do: true
  defp role_matches?(%Account{role: :both}, _), do: true
  defp role_matches?(%Account{role: role}, role), do: true
  defp role_matches?(_, _), do: false

  defp db(), do: Application.get_env(:blaine, :components)[:database]
end
