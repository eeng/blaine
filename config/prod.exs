import Config

config :blaine, :components, repository: Blaine.Persistence.Repository.Redis

config :blaine, :supervise, [
  {Redix, {System.get_env("REDIS_URL", "redis://localhost"), [name: :redix]}},
  Blaine.Persistence.Repository.Redis,
  {Blaine.Jobs.ChannelsMonitor,
   interval: String.to_integer(System.get_env("MONITOR_INTERVAL", "0")),
   lookback_span: String.to_integer(System.get_env("LOOKBACK_SPAN", "60"))}
]

config :blaine, Blaine.Google.AuthAPI,
  client_id: System.fetch_env!("GOOGLE_CLIENT_ID"),
  client_secret: System.fetch_env!("GOOGLE_CLIENT_SECRET")

config :logger, level: :info
