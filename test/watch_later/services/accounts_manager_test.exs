defmodule WatchLater.Services.AccountsManagerTest do
  use ExUnit.Case, async: true

  alias WatchLater.Services.AccountsManager
  alias WatchLater.Models.Account

  setup do
    manager = start_supervised!({AccountsManager, name: :testing_only})
    %{manager: manager}
  end

  describe "add_account" do
    test "ahould build the account and add it to the list", %{manager: m} do
      AccountsManager.add_account(m, "A", :provider)

      assert [%Account{code: "A", role: :provider}] = AccountsManager.accounts(m)

      AccountsManager.add_account(m, "B", :watcher)

      assert [%Account{code: "B", role: :watcher}, %Account{code: "A", role: :provider}] =
               AccountsManager.accounts(m)
    end
  end

  describe "accounts" do
    test "allows to filter by role", %{manager: m} do
      AccountsManager.add_account(m, "A", :provider)
      AccountsManager.add_account(m, "B", :watcher)
      assert [%Account{code: "B"}] = AccountsManager.accounts(m, :watcher)
    end
  end
end
