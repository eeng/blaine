defmodule Blaine.Application do
  use Application

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: Blaine.Supervisor]
    Supervisor.start_link(children(Mix.env()), opts)
  end

  def children(:test), do: [Blaine.Storage.Database.ETS]

  def children(:dev) do
    [
      Blaine.Storage.Database.DETS,
      Blaine.Storage.AccountsRepository,
      Blaine.Jobs.UploadsScanner
    ]
  end

  def children(:prod) do
    [
      {Redix, {Application.get_env(:redix, :url), [name: :redix]}},
      Blaine.Storage.AccountsRepository,
      Blaine.Jobs.UploadsScanner
    ]
  end
end
