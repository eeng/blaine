defmodule WatchLater.Services.AccountsManager.Behaviour do
  alias WatchLater.Entities.Account

  @callback add_account(String.t(), Account.role()) :: {:ok, Account.t()} | {:error, any}
  @callback accounts(Account.role() | :both) :: [Account.t()]
end

defmodule WatchLater.Services.AccountsManager do
  @moduledoc """
  This module allows adding Google accounts that will be used to retrieve the uploads.
  It uses the authentication API to exchange the authorization code for a token
  that is later needed to access the other APIs.
  In addition, it handles the tokens renewal.
  """

  @behaviour WatchLater.Services.AccountsManager.Behaviour

  alias WatchLater.Entities.Account

  @impl true
  def add_account(code, role) do
    with {:ok, token} <- auth_api().get_token(code),
         {:ok, profile} <- people_api().me(token),
         account <- build_account(code, role, token, profile),
         :ok <- repo().add_account(repo(), account) do
      {:ok, account}
    end
  end

  @impl true
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

  defp build_account(code, role, token, %{id: id, name: name}) do
    %Account{code: code, role: role, auth_token: token, id: id, name: name}
  end

  defp auth_api(), do: Application.get_env(:watch_later, :components)[:google_auth_api]
  defp people_api(), do: Application.get_env(:watch_later, :components)[:google_people_api]
  defp repo(), do: Application.get_env(:watch_later, :components)[:accounts_repo]
end
