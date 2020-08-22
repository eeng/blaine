defmodule WatchLater.Util.Map do
  @doc """
  Creates a map from the `list` structs indexed by the `field`.
  """
  def by(list, field) do
    list |> Enum.map(&{Map.get(&1, field), &1}) |> Enum.into(%{})
  end
end
