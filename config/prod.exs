import Config

config :watch_later, WatchLater.Google.AuthAPI,
  client_id: System.fetch_env!("GOOGLE_CLIENT_ID"),
  client_secret: System.fetch_env!("GOOGLE_CLIENT_SECRET")

config :watch_later, WatchLater.Jobs.UploadsScanner,
  interval: System.get_env("SCANNER_INTERVAL", 60 * 60)

config :logger, level: :info
