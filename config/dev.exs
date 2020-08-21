import Config

config :watch_later, :google_auth_api, WatchLater.Google.AuthAPI

import_config "#{Mix.env()}.secrets.exs"
