defmodule Persistence.Repository.Redis do
  @moduledoc """
  This GenServer handles the system persistance in a Redis database.
  """

  @behaviour Blaine.Persistance.Repository
  @ns :blaine

  @impl true
  def save_last_run_at(last_run_at) do
    store(:last_run_at, last_run_at)
  end

  @impl true
  def last_run_at() do
    get(:last_run_at)
  end

  defp store(key, value) do
    value = :erlang.term_to_binary(value)
    {:ok, _} = Redix.command(:redix, ["SET", ns_key(key), value])
    :ok
  end

  defp get(key) do
    with {:ok, value} when not is_nil(value) <- Redix.command(:redix, ["GET", ns_key(key)]) do
      :erlang.binary_to_term(value)
    else
      _ -> nil
    end
  end

  defp ns_key(key) do
    "#{@ns}.#{key}"
  end
end
