defmodule Blaine.Storage.Database do
  @callback store(atom, any) :: :ok | {:error, any}
  @callback fetch(atom) :: {:ok, any} | {:error, any}

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
