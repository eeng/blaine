import Config

config :blaine, :components, repository: Blaine.Persistence.Repository.Dets
# config :blaine, :components, repository: Blaine.Persistence.Repository.Redis

config :blaine, :supervise, [
  Blaine.Persistence.Repository.Dets,
  # {Redix, name: :redix},
  # Blaine.Persistence.Repository.Redis,
  {Blaine.Jobs.UploadsScanner, interval: 0}
]

config :logger, level: :debug

import_config "#{Mix.env()}.secrets.exs"
