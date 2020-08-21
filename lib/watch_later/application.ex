defmodule WatchLater.Application do
  use Application

  def start(_type, _args) do
    children = [
      WatchLater.Services.AccountsManager
    ]

    opts = [strategy: :one_for_one, name: WatchLater.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
