defmodule Blaine.Application do
  use Application

  def start(_type, _args) do
    children = [
      Blaine.Storage.DB,
      Blaine.Storage.AccountsRepository,
      Blaine.Jobs.UploadsScanner
    ]

    opts = [strategy: :one_for_one, name: Blaine.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
