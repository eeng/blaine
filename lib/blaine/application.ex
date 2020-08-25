defmodule Blaine.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Redix, {Application.get_env(:redix, :url), [name: :redix]}},
      Blaine.Storage.Database.ETS,
      Blaine.Storage.AccountsRepository,
      Blaine.Jobs.UploadsScanner
    ]

    opts = [strategy: :one_for_one, name: Blaine.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
