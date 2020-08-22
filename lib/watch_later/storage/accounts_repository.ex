defmodule WatchLater.Storage.AccountsRepository.Behaviour do
  @callback add_account(Account.t()) :: :ok | {:error, any}
  @callback accounts(Account.role()) :: [Account.t()]
end

defmodule WatchLater.Storage.AccountsRepository do
  @behaviour WatchLater.Storage.AccountsRepository.Behaviour
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

  @impl true
  def add_account(manager \\ @me, account) do
    GenServer.call(manager, {:add_account, account})
  end

  @impl true
  def accounts(manager \\ @me, role \\ :both) do
    GenServer.call(manager, {:get_accounts, role})
  end

  @impl true
  def init(_) do
    Process.flag(:trap_exit, true)
    {:ok, []}
  end

  # @impl true
  # def terminate(_reason, accounts) do
  #   repo().store_accounts(accounts)
  #   repo().close()
  # end

  @impl true
  def handle_call({:add_account, account}, _from, accounts) do
    {:reply, :ok, [account | accounts]}
  end

  @impl true
  def handle_call({:get_accounts, role}, _from, accounts) do
    filtered = Enum.filter(accounts, &role_matches?(&1, role))
    {:reply, filtered, accounts}
  end

  defp role_matches?(_, :both), do: true
  defp role_matches?(%Account{role: role}, role), do: true
  defp role_matches?(_, _), do: false
end
