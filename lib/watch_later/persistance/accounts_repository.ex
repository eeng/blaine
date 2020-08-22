defmodule WatchLater.Persistance.AccountsRepository do
  alias WatchLater.Models.Account

  @type state :: [Account.t()]

  @callback store_accounts(state) :: any
  @callback fetch_accounts() :: state
  @callback close() :: any
end