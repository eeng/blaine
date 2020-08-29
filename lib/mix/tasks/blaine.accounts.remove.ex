defmodule Mix.Tasks.Blaine.Accounts.Remove do
  @shortdoc "Removes a Google Account"

  @moduledoc """
  ## Arguments:

    * `--role`: provider | watcher | both
  """

  use Mix.Task

  alias Blaine.Services.AccountsManager

  def run(args) do
    Application.ensure_all_started(:blaine)

    {opts, _args} = OptionParser.parse!(args, strict: [id: :string])
    id = Keyword.fetch!(opts, :id)

    IO.puts("Removing account with ID #{id}")

    :ok = AccountsManager.remove_account(id)

    IO.puts("Done!")
  end
end
