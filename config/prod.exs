import Config

config :blaine, Blaine.Google.AuthAPI,
  client_id: System.fetch_env!("GOOGLE_CLIENT_ID"),
  client_secret: System.fetch_env!("GOOGLE_CLIENT_SECRET")

config :blaine, Blaine.Jobs.UploadsScanner,
  interval: System.get_env("SCANNER_INTERVAL", 60 * 60)

config :logger, level: :info
