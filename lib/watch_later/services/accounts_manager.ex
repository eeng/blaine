defmodule WatchLater.Services.AccountsManager do
  alias WatchLater.Models.Account

  @spec add_account(String.t(), Account.role()) :: {:ok, Account.t()} | {:error, any}
  def add_account(code, role) do
    with {:ok, token} <- auth_api().get_token(code),
         profile <- fetch_profile(token),
         account <- build_account(code, role, token, profile),
         :ok <- repo().add_account(account) do
      {:ok, account}
    end
  end

  @spec accounts(Account.role() | :both) :: [Account.t()]
  def accounts(role \\ :both) do
    repo().accounts(role)
  end

  defp fetch_profile(token) do
    people_api().me(token, personFields: "names") |> extract_profile()
  end

  defp extract_profile({:ok, profile}) do
    %{
      "names" => [
        %{"displayName" => name, "metadata" => %{"source" => %{"id" => id}}}
      ]
    } = profile

    {id, name}
  end

  defp build_account(code, role, token, {id, name}) do
    %Account{code: code, role: role, auth_token: token, id: id, name: name}
  end

  defp auth_api(), do: Application.get_env(:watch_later, :google_auth_api)
  defp people_api(), do: Application.get_env(:watch_later, :google_people_api)
  defp repo(), do: Application.get_env(:watch_later, :accounts_repo)
end
