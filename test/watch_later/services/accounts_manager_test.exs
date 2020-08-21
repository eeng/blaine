defmodule WatchLater.Services.AccountsManagerTest do
  use ExUnit.Case, async: true

  alias WatchLater.Services.AccountsManager
  alias WatchLater.Models.Account
  alias WatchLater.Google.AuthToken
  alias WatchLater.Google.{MockAuthAPI, MockPeopleAPI}

  import Mox

  setup [:verify_on_exit!, :start_manager, :stub_apis]

  describe "add_account" do
    test "should build the account and add it to the list", %{manager: m} do
      AccountsManager.add_account(m, "A", :provider)

      assert [%Account{code: "A", role: :provider}] = AccountsManager.accounts(m)

      AccountsManager.add_account(m, "B", :watcher)

      assert [%Account{code: "B", role: :watcher}, %Account{code: "A", role: :provider}] =
               AccountsManager.accounts(m)
    end

    test "should exchange the code for the token using the Auth API", %{manager: m} do
      token = %AuthToken{access_token: "at"}
      MockAuthAPI |> expect(:get_token, fn "some code" -> {:ok, token} end)
      {:ok, account} = AccountsManager.add_account(m, "some code", :provider)
      assert %Account{auth_token: ^token} = account
    end

    test "should retrieve the account profile using the People API", %{manager: m} do
      response = profile("100", "Max")

      MockAuthAPI |> expect(:get_token, fn _ -> {:ok, "a token"} end)
      MockPeopleAPI |> expect(:client, fn "a token" -> :a_client end)

      MockPeopleAPI
      |> expect(:me, fn :a_client, personFields: "names" -> {:ok, response} end)

      {:ok, account} = AccountsManager.add_account(m, "some code", :provider)
      assert %Account{name: "Max", id: "100"} = account
    end
  end

  describe "accounts" do
    test "allows to filter by role", %{manager: m} do
      AccountsManager.add_account(m, "A", :provider)
      AccountsManager.add_account(m, "B", :watcher)
      assert [%Account{code: "B"}] = AccountsManager.accounts(m, :watcher)
    end
  end

  defp start_manager(_) do
    manager = start_supervised!({AccountsManager, name: :testing_only})
    %{manager: manager}
  end

  defp stub_apis(%{manager: manager}) do
    allow(MockAuthAPI, self(), manager)
    allow(MockPeopleAPI, self(), manager)
    MockAuthAPI |> stub(:get_token, fn _ -> {:ok, :token} end)
    MockPeopleAPI |> stub(:client, fn _ -> {:ok, :client} end)
    MockPeopleAPI |> stub(:me, fn _, _ -> {:ok, profile(1, "x")} end)
    :ok
  end

  defp profile(id, name) do
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
