import Config

config :watch_later, :accounts_repo, WatchLater.Storage.MockAccountsRepository
config :watch_later, :google_auth_api, WatchLater.Google.MockAuthAPI
config :watch_later, :google_people_api, WatchLater.Google.MockPeopleAPI
