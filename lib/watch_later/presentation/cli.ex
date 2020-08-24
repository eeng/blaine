defmodule WatchLater.Presentation.CLI do
  alias WatchLater.Google.AuthAPI
  alias WatchLater.Services.{AccountsManager, NewUploadsFinder}

  def add_account(role) do
    # TODO the watcher scopes should not include the force-ssl
    # create an authorize_url(role) on the service and put the login in there
    # so this doesn't depend on the API
    scopes = ~w(
      https://www.googleapis.com/auth/userinfo.profile
      https://www.googleapis.com/auth/userinfo.email
      https://www.googleapis.com/auth/youtube.readonly
      https://www.googleapis.com/auth/youtube.force-ssl
    ) |> Enum.join(" ")

    auth_url = AuthAPI.authorize_url(scope: scopes)

    IO.puts("Visit the following URL and copy the given code:\n")
    IO.puts(auth_url <> "\n")

    code = IO.gets("Then paste the code here: ") |> String.trim()

    AccountsManager.add_account(code, role)
  end

  def find_uploads_and_add_to_watch_later(opts) do
    # TODO rename this NewUploadsFinder
    NewUploadsFinder.find_uploads_and_add_to_watch_later(opts)
  end
end
