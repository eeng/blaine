import Config

config :blaine, :components, repository: Persistence.Repository.Dets
# config :blaine, :components, repository: Persistence.Repository.Redis

config :blaine, :supervise, [
  Persistence.Repository.Dets,
  # {Redix, name: :redix},
  {Blaine.Jobs.UploadsScanner, interval: 0}
]

config :blaine, Blaine.Storage.Database.DETS, table: :blaine

config :logger, level: :debug

import_config "#{Mix.env()}.secrets.exs"
