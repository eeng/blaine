import Config

config :watch_later, :components,
  accounts_manager: WatchLater.Services.MockAccountsManager,
  uploads_service: WatchLater.Services.MockUploadsService,
  accounts_repo: WatchLater.Storage.MockAccountsRepository,
  google_auth_api: WatchLater.Google.MockAuthAPI,
  google_people_api: WatchLater.Google.MockPeopleAPI,
  google_youtube_api: WatchLater.Google.MockYouTubeAPI,
  http_client: WatchLater.Util.MockHTTP

config :watch_later, WatchLater.Storage.DB, dets_table: :watch_later_test

config :logger, level: :error
