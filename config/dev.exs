import Config

config :oauth2, debug: true

import_config "#{Mix.env()}.secrets.exs"
