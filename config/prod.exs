import Config

config :blaine, :components, repository: Persistence.Repository.Redis

config :blaine, :supervise, [
  {Redix, {System.get_env("REDIS_URL"), [name: :redix]}}
  {Blaine.Jobs.UploadsScanner,
   interval: String.to_integer(System.get_env("SCANNER_INTERVAL", "3600"))}
]

config :blaine, Blaine.Google.AuthAPI,
  client_id: System.fetch_env!("GOOGLE_CLIENT_ID"),
  client_secret: System.fetch_env!("GOOGLE_CLIENT_SECRET")

config :logger, level: :info
