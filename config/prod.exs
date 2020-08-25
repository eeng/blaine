import Config

config :watch_later, WatchLater.Jobs.UploadsScanner,
  run_every_ms: System.get_env("SCANNER_FREQUENCY", 60 * 60 * 1000)

config :logger, level: :debug
