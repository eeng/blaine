defmodule Blaine.Application do
  use Application

  def start(_type, _args) do
    children = [
      Application.get_env(:blaine, :components)[:database],
      Blaine.Storage.AccountsRepository,
      Blaine.Jobs.UploadsScanner
    ]

    opts = [strategy: :one_for_one, name: Blaine.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
