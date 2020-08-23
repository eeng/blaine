import Config

config :watch_later, :components,
  accounts_manager: WatchLater.Services.AccountsManager,
  accounts_repo: WatchLater.Storage.AccountsRepository,
  google_auth_api: WatchLater.Google.AuthAPI,
  google_people_api: WatchLater.Google.PeopleAPI,
  google_youtube_api: WatchLater.Google.YouTubeAPI,
  http_client: WatchLater.Util.HTTP

config :watch_later, WatchLater.Storage.DB, dets_table: :watch_later

config :tesla, adapter: Tesla.Adapter.Hackney

import_config "#{Mix.env()}.exs"
