defmodule WatchLater.Marshal do
  def dump(anything, path) do
    bin = :erlang.term_to_binary(anything)
    File.write!(path, bin)
  end

  def load(path) do
    File.read!(path) |> :erlang.binary_to_term()
  end
end
