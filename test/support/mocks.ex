Mox.defmock(WatchLater.Services.MockAccountsManager,
  for: WatchLater.Services.AccountsManager.Behaviour
)

Mox.defmock(WatchLater.Storage.MockAccountsRepository,
  for: WatchLater.Storage.AccountsRepository.Behaviour
)

Mox.defmock(WatchLater.Google.MockAuthAPI, for: WatchLater.Google.AuthAPI.Behaviour)
Mox.defmock(WatchLater.Google.MockPeopleAPI, for: WatchLater.Google.PeopleAPI.Behaviour)
Mox.defmock(WatchLater.Google.MockYouTubeAPI, for: WatchLater.Google.YouTubeAPI.Behaviour)

Mox.defmock(WatchLater.Util.MockHTTP, for: WatchLater.Util.HTTP.Behaviour)
Mox.defmock(WatchLater.MockClock, for: WatchLater.Util.Clock.Behaviour)
