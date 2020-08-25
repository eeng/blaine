defmodule Blaine.Storage.AccountsRepositoryTest do
  use Blaine.DataCase

  import Blaine.Factory
  alias Blaine.Storage.AccountsRepository

  setup context do
    process_name = context.test
    manager = start_supervised!({AccountsRepository, name: process_name})
    %{manager: manager, process_name: context.test}
  end

  describe "add_account" do
    test "should add the account to the list", %{manager: m} do
      [a1, a2] = build(:account, 2)
      :ok = AccountsRepository.add_account(m, a1)
      assert [a1] = AccountsRepository.accounts(m)
      AccountsRepository.add_account(m, a2)
      assert [a1, a2] = AccountsRepository.accounts(m)
    end

    test "should persist the account", %{manager: m} do
      a = build(:account, id: "787", name: "X")
      :ok = AccountsRepository.add_account(m, a)
      assert {:ok, %{"787" => a}} = db().fetch(:accounts)
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
      a1 = build(:account, name: "A1", role: :provider)
      a2 = build(:account, name: "A2", role: :watcher)
      a3 = build(:account, name: "A3", role: :both)
      AccountsRepository.add_account(m, a1)
      AccountsRepository.add_account(m, a2)
      AccountsRepository.add_account(m, a3)

      assert [%{name: "A2"}, %{name: "A3"}] =
               AccountsRepository.accounts(m, :watcher) |> Enum.sort_by(& &1.name)
    end
  end

  describe "init" do
    test "should restore the persisted accounts", %{process_name: process_name} do
      a = build(:account, id: "121")
      db().store(:accounts, %{"121" => a})
      pid = stop_process_and_get_new_pid(process_name)
      assert [a] = AccountsRepository.accounts(pid)
    end
  end

  def stop_process_and_get_new_pid(process_name) do
    GenServer.stop(process_name)
    :timer.sleep(1)
    Process.whereis(process_name)
  end
end
