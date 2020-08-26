import Config

config :blaine, :supervise, [{Blaine.Jobs.UploadsScanner, interval: 0}]

config :blaine, Blaine.Storage.Database.DETS, table: :blaine

config :logger, level: :debug

import_config "#{Mix.env()}.secrets.exs"
