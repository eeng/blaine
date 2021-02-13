defmodule Mix.Tasks.Blaine.Accounts.List do
  @shortdoc "Shows information about the added Google accounts"

  use Mix.Task

  alias Blaine.Services.AccountsManager

  def run(_args) do
    Application.ensure_all_started(:blaine)

    case AccountsManager.accounts() do
      [] ->
        IO.puts("No accounts added yet.")

      accounts ->
        IO.puts("Current Accounts:")
        Enum.each(accounts, &IO.inspect/1)
    end
  end
end
