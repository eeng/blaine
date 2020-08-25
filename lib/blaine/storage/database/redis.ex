defmodule Blaine.Storage.Database.Redis do
  @moduledoc """
  This GenServer handles the system persistance in a Redis database.
  """
  use Blaine.Storage.Database

  @ns :blaine

  @impl true
  def store(key, value) do
    value = :erlang.term_to_binary(value)
    {:ok, _} = Redix.command(:redix, ["SET", ns_key(key), value])
    :ok
  end

  @impl true
  def fetch(key) do
    with {:ok, value} when not is_nil(value) <- Redix.command(:redix, ["GET", ns_key(key)]) do
      {:ok, :erlang.binary_to_term(value)}
    else
      _ -> {:error, :not_found}
    end
  end

  def ns_key(key) do
    "#{@ns}.#{key}"
  end
end
