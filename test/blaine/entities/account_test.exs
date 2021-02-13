defmodule Blaine.Entities.AccountTest do
  use ExUnit.Case, async: true

  import Blaine.Factory
  alias Blaine.Entities.Account

  describe "build" do
    test "valid role is required" do
      assert {:error, :missing_role} = Account.build(account_fields(role: nil))
      assert {:error, :missing_role} = Account.build(account_fields(role: :other))
    end

    test "watcher role needs add_to_playlist_id" do
      assert {:error, :missing_add_to_playlist_id} = Account.build(account_fields(role: :watcher))
      assert {:error, :missing_add_to_playlist_id} = Account.build(account_fields(role: :both))

      assert {:ok, %Account{}} =
               Account.build(account_fields(role: :watcher, add_to_playlist_id: "WL"))

      assert {:ok, %Account{}} = Account.build(account_fields(role: :provider))
    end

    defp account_fields(fields) do
      Enum.into(fields, Map.from_struct(build(:account)))
    end
  end
end
