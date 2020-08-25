defmodule Blaine.Presentation.CLI do
  alias Blaine.Services.{AccountsManager, UploadsService}

  def add_account(role) do
    auth_url = AccountsManager.authorize_url_for(role)

    IO.puts("Visit the following URL and copy the given code:\n")
    IO.puts(auth_url <> "\n")

    code = IO.gets("Then paste the code here: ") |> String.trim()

    AccountsManager.add_account(code, role)
  end

  def find_uploads_and_add_to_blaine(opts) do
    UploadsService.find_uploads_and_add_to_blaine(opts)
  end
end
