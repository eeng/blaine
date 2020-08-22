defmodule WatchLater.Persistance.AccountsRepository.InMemory do
  @behaviour WatchLater.Persistance.AccountsRepository

  @impl true
  def store_accounts(_) do
  end

  @impl true
  def fetch_accounts() do
    []
  end

  @impl true
  def close do
  end
end
