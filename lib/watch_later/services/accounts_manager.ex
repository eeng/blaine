defmodule WatchLater.Services.AccountsManager do
  use GenServer
  alias WatchLater.Models.Account

  @me __MODULE__

  def start_link(opts) do
    name = Keyword.get(opts, :name, @me)
    GenServer.start_link(@me, [], name: name)
  end

  def stop(manager) do
    GenServer.stop(manager)
  end

  @spec add_account(atom(), String.t(), Account.role()) :: Account.t()
  def add_account(manager \\ @me, code, role) do
    GenServer.call(manager, {:add_account, code, role})
  end

  @spec accounts(atom(), Account.role() | :all) :: [Account.t()]
  def accounts(manager \\ @me, role \\ :all) do
    GenServer.call(manager, {:get_accounts, role})
  end

  @impl true
  def init(accounts) do
    {:ok, accounts}
  end

  @impl true
  def handle_call({:add_account, code, role}, _from, accounts) do
    account = %Account{code: code, role: role}
    {:reply, account, [account | accounts]}
  end

  @impl true
  def handle_call({:get_accounts, role}, _from, accounts) do
    filtered = Enum.filter(accounts, &role_matches?(&1, role))
    {:reply, filtered, accounts}
  end

  defp role_matches?(_, :all), do: true
  defp role_matches?(%Account{role: role}, role), do: true
  defp role_matches?(_, _), do: false
end
