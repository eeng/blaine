import Config

config :tesla, Tesla.Middleware.Logger, debug: false

import_config "#{Mix.env()}.secrets.exs"
