defmodule WatchLater.Services.AccountsManagerTest do
  use ExUnit.Case, async: true

  alias WatchLater.Services.AccountsManager
  alias WatchLater.Models.Account
  alias WatchLater.Google.AuthToken
  alias WatchLater.Google.MockAuthAPI

  import Mox

  setup [:verify_on_exit!, :start_manager, :stub_api]

  describe "add_account" do
    test "should build the account and add it to the list", %{manager: m} do
      AccountsManager.add_account(m, "A", :provider)

      assert [%Account{code: "A", role: :provider}] = AccountsManager.accounts(m)

      AccountsManager.add_account(m, "B", :watcher)

      assert [%Account{code: "B", role: :watcher}, %Account{code: "A", role: :provider}] =
               AccountsManager.accounts(m)
    end

    test "should exchange the code for the token using the auth API", %{manager: m} do
      token = %AuthToken{access_token: "at"}
      MockAuthAPI |> expect(:get_token, fn "some code" -> {:ok, token} end)
      {:ok, account} = AccountsManager.add_account(m, "some code", :provider)
      assert %{auth_token: ^token} = account
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

  defp stub_api(%{manager: manager}) do
    allow(MockAuthAPI, self(), manager)
    MockAuthAPI |> stub(:get_token, fn _ -> {:ok, :token} end)
    :ok
  end
end
