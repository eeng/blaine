defmodule Blaine.Persistance.Repository do
  @moduledoc """
  Behaviour to be implemented by the repository adapters.
  """

  alias Blaine.Entities.Account

  @callback add_account(Account.t()) :: :ok
  @callback remove_account(String.t()) :: :ok
  @callback accounts(Account.role()) :: [Account.t()]

  @callback save_last_run_at(DateTime.t()) :: :ok
  @callback last_run_at() :: DateTime.t() | nil

  defmacro __using__(_opts) do
    quote do
      @behaviour Blaine.Persistance.Repository

      alias Blaine.Persistance.Repository

      defp role_matches?(_, :both), do: true
      defp role_matches?(%Account{role: :both}, _), do: true
      defp role_matches?(%Account{role: role}, role), do: true
      defp role_matches?(_, _), do: false
    end
  end
end
