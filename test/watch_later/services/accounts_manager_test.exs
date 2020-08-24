defmodule WatchLater.Services.AccountsManagerTest do
  use ExUnit.Case, async: true

  alias WatchLater.Services.AccountsManager
  alias WatchLater.Entities.Account
  alias WatchLater.Google.AuthToken
  alias WatchLater.Google.{MockAuthAPI, MockPeopleAPI}
  alias WatchLater.Storage.MockAccountsRepository
  import WatchLater.Factory
  import Mox

  setup :verify_on_exit!

  describe "authorize_url" do
    test "for :provider role" do
      scopes = ~w(
        https://www.googleapis.com/auth/userinfo.profile
        https://www.googleapis.com/auth/userinfo.email
        https://www.googleapis.com/auth/youtube.readonly
      ) |> Enum.join(" ")

      MockAuthAPI |> expect(:authorize_url, fn scope: ^scopes -> "the url" end)
      assert "the url" = AccountsManager.authorize_url_for(:provider)
    end

    test "for :watcher role" do
      scopes = ~w(
        https://www.googleapis.com/auth/userinfo.profile
        https://www.googleapis.com/auth/userinfo.email
        https://www.googleapis.com/auth/youtube.readonly
        https://www.googleapis.com/auth/youtube.force-ssl
      ) |> Enum.join(" ")

      MockAuthAPI |> expect(:authorize_url, 2, fn scope: ^scopes -> "the url" end)
      assert "the url" = AccountsManager.authorize_url_for(:watcher)
      assert "the url" = AccountsManager.authorize_url_for(:both)
    end
  end

  describe "add_account" do
    setup do
      MockAuthAPI |> stub(:get_token, fn _ -> {:ok, :token} end)
      MockPeopleAPI |> stub(:me, fn _ -> profile_response(1, "x") end)
      MockAccountsRepository |> stub(:add_account, fn _, _ -> :ok end)
      :ok
    end

    test "should exchange the code for the token using the Auth API" do
      token = %AuthToken{access_token: "at"}
      MockAuthAPI |> expect(:get_token, fn "some code" -> {:ok, token} end)
      {:ok, account} = AccountsManager.add_account("some code", :provider)
      assert %Account{auth_token: ^token} = account
    end

    test "should retrieve the account profile using the People API" do
      response = profile_response("100", "Max")

      MockAuthAPI |> expect(:get_token, fn _ -> {:ok, "token"} end)
      MockPeopleAPI |> expect(:me, fn "token" -> response end)

      {:ok, account} = AccountsManager.add_account("code", :provider)
      assert %Account{id: "100", name: "Max"} = account
    end

    test "should add the account to the repo" do
      MockAccountsRepository |> expect(:add_account, fn _, %{code: "A"} -> :ok end)
      AccountsManager.add_account("A", :provider)
    end
  end

  describe "accounts" do
    test "fetches the accounts from the repo" do
      MockAuthAPI |> stub(:renew_token, fn _ -> :still_valid end)

      a = build(:account, id: "121", role: :watcher)
      MockAccountsRepository |> expect(:accounts, fn _, :watcher -> [a] end)
      assert [a] = AccountsManager.accounts(:watcher)
    end
  end

  defp profile_response(id, name) do
    {:ok, %{id: id, name: name}}
  end
end
