import Config

config :watch_later, :accounts_repo, WatchLater.Storage.AccountsRepository
config :watch_later, :google_auth_api, WatchLater.Google.AuthAPI
config :watch_later, :google_people_api, WatchLater.Google.PeopleAPI

config :tesla, adapter: Tesla.Adapter.Hackney

import_config "#{Mix.env()}.exs"
