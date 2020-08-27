Mox.defmock(Blaine.Services.MockAccountsManager,
  for: Blaine.Services.AccountsManager.Behaviour
)

Mox.defmock(Blaine.Services.MockUploadsService,
  for: Blaine.Services.UploadsService.Behaviour
)

Mox.defmock(Blaine.Google.MockAuthAPI, for: Blaine.Google.AuthAPI.Behaviour)
Mox.defmock(Blaine.Google.MockPeopleAPI, for: Blaine.Google.PeopleAPI.Behaviour)
Mox.defmock(Blaine.Google.MockYouTubeAPI, for: Blaine.Google.YouTubeAPI.Behaviour)

Mox.defmock(Blaine.Util.MockHTTP, for: Blaine.Util.HTTP.Behaviour)
Mox.defmock(Blaine.MockClock, for: Blaine.Util.Clock.Behaviour)

defmodule Blaine.Mocks do
  defmacro __using__(_opts) do
    quote do
      import Mox
      setup :verify_on_exit!
    end
  end
end
