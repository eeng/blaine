import Config

config :blaine, :components,
  accounts_manager: Blaine.Services.AccountsManager,
  uploads_service: Blaine.Services.UploadsService,
  accounts_repo: Blaine.Storage.AccountsRepository,
  google_auth_api: Blaine.Google.AuthAPI,
  google_people_api: Blaine.Google.PeopleAPI,
  google_youtube_api: Blaine.Google.YouTubeAPI,
  http_client: Blaine.Util.HTTP,
  database: Blaine.Storage.Database.DETS

config :blaine, Blaine.Storage.Database.DETS, dets_table: :blaine

config :blaine, Blaine.Jobs.UploadsScanner, interval: 0

config :logger,
  backends: [:console]

config :logger, :console,
  format: "$time $metadata[$level] $levelpad$message\n",
  metadata: [:module]

config :tesla, adapter: Tesla.Adapter.Hackney

import_config "#{Mix.env()}.exs"
