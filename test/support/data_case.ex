defmodule Blaine.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring access to the database.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      defp db(), do: Application.get_env(:blaine, :components)[:database]

      setup do
        on_exit(fn -> db().destroy() end)
      end
    end
  end
end
