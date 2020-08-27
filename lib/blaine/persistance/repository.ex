defmodule Blaine.Persistance.Repository do
  @moduledoc """
  Behaviour to be implemented by the repository adapters.
  """

  # @callback add_account(Account.t()) :: :ok
  # @callback remove_account(String.t()) :: :ok
  # @callback accounts(Account.role()) :: [Account.t()]

  @callback save_last_run_at(DateTime.t()) :: :ok
  @callback last_run_at() :: DateTime.t() | nil
end
