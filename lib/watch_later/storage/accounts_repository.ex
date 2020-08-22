defmodule WatchLater.Storage.AccountsRepository.Behaviour do
  @callback add_account(any, Account.t()) :: :ok | {:error, any}
  @callback accounts(any, Account.role()) :: [Account.t()]
end

defmodule WatchLater.Storage.AccountsRepository do
  @behaviour WatchLater.Storage.AccountsRepository.Behaviour
  use GenServer

  alias WatchLater.Entities.Account
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
  def add_account(server, account) do
    GenServer.call(server, {:add_account, account})
  end

  @impl true
  def accounts(server, role \\ :both) do
    GenServer.call(server, {:get_accounts, role})
  end

  @impl true
  def init(_) do
    {:ok, db} = DB.open()

    accounts =
      case DB.fetch(db, :accounts) do
        {:ok, accounts} -> accounts
        _ -> %{}
      end

    {:ok, %State{accounts: accounts, db: db}}
  end

  @impl true
  def terminate(_reason, %{db: db}) do
    DB.close(db)
  end

  @impl true
  def handle_call({:add_account, account}, _from, %{db: db, accounts: accounts} = state) do
    new_accounts = accounts |> Map.put(account.id, account)
    :ok = DB.store(db, :accounts, new_accounts)
    {:reply, :ok, %{state | accounts: new_accounts}}
  end

  @impl true
  def handle_call({:get_accounts, role}, _from, %{accounts: accounts} = state) do
    filtered = accounts |> Map.values() |> Enum.filter(&role_matches?(&1, role))
    {:reply, filtered, state}
  end

  defp role_matches?(_, :both), do: true
  defp role_matches?(%Account{role: role}, role), do: true
  defp role_matches?(_, _), do: false
end
