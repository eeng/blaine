defmodule WatchLater.Persistance.AccountsRepository.DETS do
  @behaviour WatchLater.Persistance.AccountsRepository

  @dets_file 'watch_later.db'
  @table :db

  @impl true
  def store_accounts(accounts) do
    :dets.insert(@table, {:accounts, accounts})
  end

  @impl true
  def fetch_accounts() do
    :dets.open_file(@table, file: @dets_file)

    case :dets.lookup(@table, :accounts) do
      [accounts: accounts] -> accounts
      _ -> []
    end
  end

  @impl true
  def close do
    :dets.close(@table)
  end
end
