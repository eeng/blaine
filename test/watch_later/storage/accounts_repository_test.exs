defmodule WatchLater.Storage.AccountsRepositoryTest do
  use ExUnit.Case, async: true

  import WatchLater.Factory
  alias WatchLater.Storage.AccountsRepository
  alias WatchLater.Storage.DB

  setup context do
    manager = start_supervised!({AccountsRepository, name: context.test})
    %{db: db} = :sys.get_state(context.test)
    on_exit(fn -> DB.destroy(db) end)
    %{manager: manager, db: db}
  end

  describe "add_account" do
    test "should add the account to the list", %{manager: m} do
      [a1, a2] = build(:account, 2)
      :ok = AccountsRepository.add_account(m, a1)
      assert [a1] = AccountsRepository.accounts(m)
      AccountsRepository.add_account(m, a2)
      assert [a1, a2] = AccountsRepository.accounts(m)
    end

    test "should persist the account", %{manager: m, db: db} do
      a = build(:account, id: "787", name: "X")
      :ok = AccountsRepository.add_account(m, a)
      assert {:ok, %{"787" => a}} = DB.fetch(db, :accounts)
    end

    test "should override the account if already exists by id", %{manager: m} do
      a = build(:account, id: "454")
      :ok = AccountsRepository.add_account(m, a)
      :ok = AccountsRepository.add_account(m, a)
      assert [a] = AccountsRepository.accounts(m)
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

  describe "init" do
    test "should restore the persisted accounts", %{manager: m, db: db, test: test} do
      a = build(:account, id: "121")
      DB.store(db, :accounts, %{"121" => a})
      GenServer.stop(m)
      :timer.sleep(1)
      assert [a] = Process.whereis(test) |> AccountsRepository.accounts()
    end
  end
end
