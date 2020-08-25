import Config

config :watch_later, WatchLater.Jobs.UploadsScanner,
  interval: System.get_env("SCANNER_INTERVAL", 60 * 60)

config :logger, level: :info
