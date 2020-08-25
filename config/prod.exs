import Config

config :blaine, Blaine.Google.AuthAPI,
  client_id: System.fetch_env!("GOOGLE_CLIENT_ID"),
  client_secret: System.fetch_env!("GOOGLE_CLIENT_SECRET")

config :blaine, Blaine.Jobs.UploadsScanner,
  interval: String.to_integer(System.get_env("SCANNER_INTERVAL", "3600"))

config :redix, url: System.get_env("REDIS_URL")

config :logger, level: :info
