Mox.defmock(WatchLater.MockClock, for: WatchLater.Util.Clock.Behaviour)

Mox.defmock(WatchLater.Storage.MockAccountsRepository,
  for: WatchLater.Storage.AccountsRepository.Behaviour
)

Mox.defmock(WatchLater.Google.MockAuthAPI, for: WatchLater.Google.Behaviours.AuthAPI)
Mox.defmock(WatchLater.Google.MockPeopleAPI, for: WatchLater.Google.Behaviours.PeopleAPI)
