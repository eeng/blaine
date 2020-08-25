import Config

config :blaine, :components,
  accounts_manager: Blaine.Services.MockAccountsManager,
  uploads_service: Blaine.Services.MockUploadsService,
  accounts_repo: Blaine.Storage.MockAccountsRepository,
  google_auth_api: Blaine.Google.MockAuthAPI,
  google_people_api: Blaine.Google.MockPeopleAPI,
  google_youtube_api: Blaine.Google.MockYouTubeAPI,
  http_client: Blaine.Util.MockHTTP,
  database: Blaine.Storage.Database.ETS

config :blaine, Blaine.Storage.Database.ETS, table: :blaine_test

config :logger, level: :error
