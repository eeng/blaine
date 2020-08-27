import Config

config :blaine, :components,
  accounts_manager: Blaine.Services.MockAccountsManager,
  uploads_service: Blaine.Services.MockUploadsService,
  google_auth_api: Blaine.Google.MockAuthAPI,
  google_people_api: Blaine.Google.MockPeopleAPI,
  google_youtube_api: Blaine.Google.MockYouTubeAPI,
  http_client: Blaine.Util.MockHTTP,
  repository: Blaine.FakeRepository

config :logger, level: :error
