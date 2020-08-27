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

  describe "last_run_at" do
    test "should allow to set it and retrieve it" do
      t = DateTime.utc_now()
      refute DetsRepository.last_run_at()
      assert :ok = DetsRepository.save_last_run_at(t)
      assert t = DetsRepository.last_run_at()
    end
  end
end
