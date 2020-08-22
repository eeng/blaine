defmodule WatchLater.Services.AccountsManager do
  alias WatchLater.Entities.Account

  @spec add_account(String.t(), Account.role()) :: {:ok, Account.t()} | {:error, any}
  def add_account(code, role) do
    with {:ok, token} <- auth_api().get_token(code),
         profile <- fetch_profile(token),
         account <- build_account(code, role, token, profile),
         :ok <- repo().add_account(repo(), account) do
      {:ok, account}
    end
  end

  @spec accounts(Account.role() | :both) :: [Account.t()]
  def accounts(role \\ :both) do
    repo().accounts(repo(), role) |> Enum.map(&renew_token_if_necessary/1)
  end

  def renew_token_if_necessary(%{auth_token: auth_token} = account) do
    case auth_api().renew_token(auth_token) do
      :still_valid ->
        account

      {:ok, new_token} ->
        new_account = %{account | auth_token: new_token}
        repo().add_account(repo(), new_account)
        new_account
    end
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

  defp auth_api(), do: Application.get_env(:watch_later, :components)[:google_auth_api]
  defp people_api(), do: Application.get_env(:watch_later, :components)[:google_people_api]
  defp repo(), do: Application.get_env(:watch_later, :components)[:accounts_repo]
end
