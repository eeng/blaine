defmodule WatchLater.Services.AccountsManagerTest do
  use ExUnit.Case, async: true

  alias WatchLater.Services.AccountsManager
  alias WatchLater.Models.Account
  alias WatchLater.Google.AuthToken
  alias WatchLater.Google.{MockAuthAPI, MockPeopleAPI}
  alias WatchLater.Storage.MockAccountsRepository

  import Mox

  setup [:verify_on_exit!, :stub_apis]

  describe "add_account" do
    test "should exchange the code for the token using the Auth API" do
      token = %AuthToken{access_token: "at"}
      MockAuthAPI |> expect(:get_token, fn "some code" -> {:ok, token} end)
      {:ok, account} = AccountsManager.add_account("some code", :provider)
      assert %Account{auth_token: ^token} = account
    end

    test "should retrieve the account profile using the People API" do
      response = profile_response("100", "Max")

      MockAuthAPI |> expect(:get_token, fn _ -> {:ok, "token"} end)
      MockPeopleAPI |> expect(:me, fn "token", personFields: "names" -> {:ok, response} end)

      {:ok, account} = AccountsManager.add_account("code", :provider)
      assert %Account{id: "100", name: "Max"} = account
    end

    test "should add the account to the repo" do
      MockAccountsRepository |> expect(:add_account, fn %{code: "A"} -> :ok end)
      AccountsManager.add_account("A", :provider)
    end
  end

  describe "accounts" do
    test "fetches the accounts from the repo" do
      MockAccountsRepository |> expect(:accounts, fn :watcher -> [] end)
      assert [] = AccountsManager.accounts(:watcher)
    end
  end

  defp stub_apis(_) do
    MockAuthAPI |> stub(:get_token, fn _ -> {:ok, :token} end)
    MockPeopleAPI |> stub(:me, fn _, _ -> {:ok, profile_response(1, "x")} end)
    MockAccountsRepository |> stub(:add_account, fn _ -> :ok end)
    :ok
  end

  defp profile_response(id, name) do
    %{
      "names" => [
        %{
          "displayName" => name,
          "metadata" => %{
            "source" => %{"id" => id}
          }
        }
      ]
    }
  end
end
