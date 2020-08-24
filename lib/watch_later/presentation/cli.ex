defmodule WatchLater.Presentation.CLI do
  alias WatchLater.Services.{AccountsManager, UploadsScanner}

  def add_account(role) do
    auth_url = AccountsManager.authorize_url_for(role)

    IO.puts("Visit the following URL and copy the given code:\n")
    IO.puts(auth_url <> "\n")

    code = IO.gets("Then paste the code here: ") |> String.trim()

    AccountsManager.add_account(code, role)
  end

  def find_uploads_and_add_to_watch_later(opts) do
    UploadsScanner.find_uploads_and_add_to_watch_later(opts)
  end
end
