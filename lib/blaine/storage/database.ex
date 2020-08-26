defmodule Blaine.Storage.Database do
  # TODO add doc and perhaps move to match https://github.com/quantum-elixir/quantum-core/blob/master/lib/quantum/storage.ex
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
