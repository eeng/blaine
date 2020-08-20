import Config

config :tesla, adapter: Tesla.Adapter.Hackney

# To keep dialyzer happy
config :watch_later, WatchLater.GoogleAuth, %{}

import_config "#{Mix.env()}.exs"
