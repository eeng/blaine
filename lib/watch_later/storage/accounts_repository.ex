defmodule WatchLater.Storage.AccountsRepository.Behaviour do
  @callback add_account(Account.t()) :: :ok | {:error, any}
  @callback accounts(Account.role()) :: [Account.t()]
end

defmodule WatchLater.Storage.AccountsRepository do
  @behaviour WatchLater.Storage.AccountsRepository.Behaviour
  use GenServer

  alias WatchLater.Models.Account
  alias WatchLater.Storage.DB

  @me __MODULE__

  defmodule State do
    defstruct [:accounts, :db]
  end

  def start_link(opts) do
    name = Keyword.get(opts, :name, @me)
    GenServer.start_link(@me, [], name: name)
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
    {:ok, db} = DB.open()
    accounts = case DB.fetch(db, :accounts) do
      {:ok, accounts} -> accounts
      _ -> []
    end
    {:ok, %State{accounts: accounts, db: db}}
  end

  @impl true
  def terminate(_reason, %{db: db}) do
    DB.close(db)
  end

  @impl true
  def handle_call({:add_account, account}, _from, %{db: db, accounts: accounts} = state) do
    new_accounts = [account | accounts]
    :ok = DB.store(db, :accounts, new_accounts)
    {:reply, :ok, %{state | accounts: new_accounts}}
  end

  @impl true
  def handle_call({:get_accounts, role}, _from, %{accounts: accounts} = state) do
    filtered = Enum.filter(accounts, &role_matches?(&1, role))
    {:reply, filtered, state}
  end

  defp role_matches?(_, :both), do: true
  defp role_matches?(%Account{role: role}, role), do: true
  defp role_matches?(_, _), do: false
end
