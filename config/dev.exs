import Config

config :watch_later, :google_auth_api, WatchLater.Google.AuthAPI
config :watch_later, :google_people_api, WatchLater.Google.PeopleAPI

import_config "#{Mix.env()}.secrets.exs"
