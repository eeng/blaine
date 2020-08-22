import Config

config :watch_later, :components,
  accounts_repo: WatchLater.Storage.AccountsRepository,
  google_auth_api: WatchLater.Google.AuthAPI,
  google_people_api: WatchLater.Google.PeopleAPI

config :tesla, adapter: Tesla.Adapter.Hackney

import_config "#{Mix.env()}.exs"
