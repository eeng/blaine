defmodule WatchLater.Storage.AccountsRepositoryTest do
  use ExUnit.Case, async: true

  import WatchLater.Factory
  alias WatchLater.Storage.AccountsRepository

  setup context do
    manager = start_supervised!({AccountsRepository, name: context.test})
    %{manager: manager}
  end

  describe "add_account" do
    test "should add the account to the list", %{manager: m} do
      [a1, a2] = build(:account, 2)
      :ok = AccountsRepository.add_account(m, a1)
      assert [a1] = AccountsRepository.accounts(m)
      AccountsRepository.add_account(m, a2)
      assert [a2, a1] = AccountsRepository.accounts(m)
    end
  end

  describe "accounts" do
    test "allows to filter by role", %{manager: m} do
      a1 = build(:account, name: "A", role: :provider)
      a2 = build(:account, name: "B", role: :watcher)
      AccountsRepository.add_account(m, a1)
      AccountsRepository.add_account(m, a2)
      assert [%{name: "B"}] = AccountsRepository.accounts(m, :watcher)
    end
  end
end
