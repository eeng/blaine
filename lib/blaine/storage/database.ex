defmodule Blaine.Storage.Database do
  @callback store(atom, any) :: :ok | {:error, any}
  @callback fetch(atom) :: {:ok, any} | {:error, any}

  @doc """
  Used mainly for testing.
  Should clear the database content.
  """
  @callback destroy() :: :ok | {:error, any}

  defmacro __using__(_opts) do
    quote do
      @behaviour Blaine.Storage.Database

      @spec get(atom) :: any
      def get(key) do
        case fetch(key) do
          {:ok, value} -> value
          _ -> nil
        end
      end
    end
  end
end
