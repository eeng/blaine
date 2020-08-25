defmodule Blaine.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the DB.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias Blaine.Storage.DB

      setup do
        on_exit(fn -> DB.destroy() end)
      end
    end
  end
end
