defmodule Mix.Tasks.Blaine.Accounts.List do
  @shortdoc "Shows information about the added Google accounts"

  use Mix.Task

  alias Blaine.Services.AccountsManager
  alias Blaine.Entities.Account

  def run(_args) do
    Application.ensure_all_started(:blaine)

    case AccountsManager.accounts() do
      [] ->
        IO.puts("No accounts added yet.")

      accounts ->
        IO.puts("Current Accounts:")
        Enum.each(accounts, &print_account_details/1)
    end
  end

  defp print_account_details(%Account{id: id, name: name, email: email, role: role}) do
    IO.puts("")
    IO.puts("Name: #{name}")
    IO.puts("Email: #{email}")
    IO.puts("ID: #{id}")
    IO.puts("Role: #{role}")
  end
end
