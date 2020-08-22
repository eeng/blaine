import Config

config :watch_later, :components,
  accounts_repo: WatchLater.Storage.MockAccountsRepository,
  google_auth_api: WatchLater.Google.MockAuthAPI,
  google_people_api: WatchLater.Google.MockPeopleAPI

config :watch_later, WatchLater.Storage.DB, dets_table: :watch_later_test
