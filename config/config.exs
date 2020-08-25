import Config

config :watch_later, :components,
  accounts_manager: WatchLater.Services.AccountsManager,
  uploads_service: WatchLater.Services.UploadsService,
  accounts_repo: WatchLater.Storage.AccountsRepository,
  google_auth_api: WatchLater.Google.AuthAPI,
  google_people_api: WatchLater.Google.PeopleAPI,
  google_youtube_api: WatchLater.Google.YouTubeAPI,
  http_client: WatchLater.Util.HTTP

config :watch_later, WatchLater.Storage.DB, dets_table: :watch_later

config :watch_later, WatchLater.Jobs.UploadsScanner, run_every_ms: 0

config :logger,
  backends: [:console]

config :logger, :console,
  format: "$time $metadata[$level] $levelpad$message\n",
  metadata: [:module]

config :tesla, adapter: Tesla.Adapter.Hackney

import_config "#{Mix.env()}.exs"
