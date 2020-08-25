import Config

config :blaine, :components,
  accounts_manager: Blaine.Services.MockAccountsManager,
  uploads_service: Blaine.Services.MockUploadsService,
  accounts_repo: Blaine.Storage.MockAccountsRepository,
  google_auth_api: Blaine.Google.MockAuthAPI,
  google_people_api: Blaine.Google.MockPeopleAPI,
  google_youtube_api: Blaine.Google.MockYouTubeAPI,
  http_client: Blaine.Util.MockHTTP

config :blaine, Blaine.Storage.DB, dets_table: :blaine_test

config :logger, level: :error
