defmodule Mix.Tasks.Blaine.Accounts.Add do
  @shortdoc "Adds a Google Account to the application"

  @moduledoc """
  ## Arguments:

    * `--role`: provider | watcher | both
    * `--add-to-playlist-id`: For watcher role, indicates where to add the videos
  """

  use Mix.Task

  alias Blaine.Services.AccountsManager

  def run(args) do
    Application.ensure_all_started(:blaine)

    {opts, _args} =
      OptionParser.parse!(args, switches: [role: :string, add_to_playlist_id: :string])

    role = Keyword.fetch!(opts, :role) |> String.to_atom()
    add_to_playlist_id = Keyword.get(opts, :add_to_playlist_id)

    auth_url = AccountsManager.authorize_url_for(role)

    IO.puts("Visit the following URL and copy the given code:\n")
    IO.puts(auth_url <> "\n")

    code = IO.gets("Then paste the given code here: ") |> String.trim()

    {:ok, account} =
      AccountsManager.add_account(code, role: role, add_to_playlist_id: add_to_playlist_id)

    IO.puts("\nWell done! Account Details:\n")
    IO.puts("ID: #{account.id}")
    IO.puts("Name: #{account.name}")
    IO.puts("E-mail: #{account.email}")
  end
end
