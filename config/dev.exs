import Config

config :blaine, :components, repository: Persistence.Repository.Dets

config :blaine, :supervise, [
  Persistence.Repository.Dets,
  {Blaine.Jobs.UploadsScanner, interval: 0}
]

config :blaine, Blaine.Storage.Database.DETS, table: :blaine

config :logger, level: :debug

import_config "#{Mix.env()}.secrets.exs"
