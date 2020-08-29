defmodule Blaine.Services.AccountsManager.Behaviour do
  alias Blaine.Entities.Account

  @callback authorize_url_for(Account.role()) :: String.t()
  @callback add_account(String.t(), Account.role()) :: {:ok, Account.t()} | {:error, any}
  @callback remove_account(String.t()) :: :ok
  @callback accounts(Account.role() | :both) :: [Account.t()]
end

defmodule Blaine.Services.AccountsManager do
  @moduledoc """
  This module allows adding Google accounts that will be used to retrieve the uploads.
  It uses the authentication API to exchange the authorization code for a token
  that is later needed to access the other APIs.
  In addition, it handles the tokens renewal.
  """

  @behaviour Blaine.Services.AccountsManager.Behaviour

  @provider_scopes ~w(
    https://www.googleapis.com/auth/userinfo.profile
    https://www.googleapis.com/auth/userinfo.email
    https://www.googleapis.com/auth/youtube.readonly
  )
  @watcher_scopes @provider_scopes ++ ~w(
    https://www.googleapis.com/auth/youtube.force-ssl
  )

  @auth_api Application.get_env(:blaine, :components)[:google_auth_api]
  @people_api Application.get_env(:blaine, :components)[:google_people_api]
  @repository Application.get_env(:blaine, :components)[:repository]

  alias Blaine.Entities.Account

  @impl true
  def authorize_url_for(role) do
    @auth_api.authorize_url(scope: scopes_for(role) |> Enum.join(" "))
  end

  defp scopes_for(:provider), do: @provider_scopes
  defp scopes_for(:watcher), do: @watcher_scopes
  defp scopes_for(:both), do: @watcher_scopes

  @impl true
  def add_account(code, role) do
    with {:ok, token} <- @auth_api.get_token(code),
         {:ok, profile} <- @people_api.me(token),
         account <- build_account(code, role, token, profile),
         @repository.add_account(account) do
      {:ok, account}
    end
  end

  @impl true
  def remove_account(id) do
    @repository.remove_account(id)
  end

  @impl true
  def accounts(role \\ :both) do
    @repository.accounts(role) |> Enum.map(&renew_token_if_necessary/1)
  end

  def renew_token_if_necessary(%{auth_token: auth_token} = account) do
    case @auth_api.renew_token(auth_token) do
      :still_valid ->
        account

      {:ok, new_token} ->
        new_account = %{account | auth_token: new_token}
        @repository.add_account(new_account)
        new_account
    end
  end

  defp build_account(code, role, token, profile) do
    %Account{code: code, role: role, auth_token: token}
    |> struct(profile)
  end
end
