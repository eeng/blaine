defmodule Persistence.Repository.DetsTest do
  use ExUnit.Case, async: true

  import Blaine.Factory

  alias Blaine.Persistence.Repository.Dets, as: DetsRepository

  setup context do
    table = context.test
    start_supervised!({DetsRepository, table: table})
    on_exit(fn -> File.rm("priv/#{table}.db") end)
    :ok
  end

  describe "add_account" do
    test "should override existing account by id" do
      a = build(:account, name: "old")

      DetsRepository.add_account(a)
      assert [%{name: "old"}] = DetsRepository.accounts(:both)

      DetsRepository.add_account(%{a | name: "new"})
      assert [%{name: "new"}] = DetsRepository.accounts(:both)
    end
  end

  describe "accounts" do
    test "should allow to get accounts of a certain role" do
      a1 = build(:account, role: :provider, name: "a1")
      a2 = build(:account, role: :watcher, name: "a1")
      a3 = build(:account, role: :both, name: "a1")

      [a1, a2, a3] |> Enum.each(&DetsRepository.add_account/1)

      assert [^a1, ^a2, ^a3] = DetsRepository.accounts(:both) |> Enum.sort_by(& &1.name)
      assert [^a1, ^a3] = DetsRepository.accounts(:provider) |> Enum.sort_by(& &1.name)
      assert [^a2, ^a3] = DetsRepository.accounts(:watcher) |> Enum.sort_by(& &1.name)
    end
  end

  describe "last_run_at" do
    test "should allow to set it and retrieve it" do
      t = DateTime.utc_now()
      refute DetsRepository.last_run_at()
      assert :ok = DetsRepository.save_last_run_at(t)
      assert t = DetsRepository.last_run_at()
    end
  end
end
