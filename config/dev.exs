import Config

# config :blaine, :components, database: Blaine.Storage.Database.DETS

config :blaine, Blaine.Storage.Database.DETS, table: :blaine

config :logger, level: :debug

import_config "#{Mix.env()}.secrets.exs"
