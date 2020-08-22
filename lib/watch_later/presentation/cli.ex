defmodule WatchLater.Presentation.CLI do
  alias WatchLater.Google.AuthAPI
  alias WatchLater.Services.AccountsManager

  def add_account(role) do
    scopes = ~w(
      https://www.googleapis.com/auth/userinfo.profile
      https://www.googleapis.com/auth/youtube.readonly
    ) |> Enum.join(" ")

    auth_url = AuthAPI.authorize_url(scope: scopes)

    IO.puts("Visit the following URL and copy the given code:\n")
    IO.puts(auth_url <> "\n")

    code = IO.gets("Then paste the code here: ") |> String.trim()

    AccountsManager.add_account(code, role)
  end
end
