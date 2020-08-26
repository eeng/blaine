defmodule Blaine.Persistance.Repository do
  @moduledoc """
  Behaviour to be implemented by the repository adapters.
  """

  @callback last_run_at() :: DateTime.t() | nil
  @callback save_last_run_at(DateTime.t()) :: :ok
end
