import Config

config :logger, level: :debug

import_config "#{Mix.env()}.secrets.exs"
