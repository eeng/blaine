defmodule Watchlater.Support.Fixtures do
  def fixture(file) do
    Path.dirname(__ENV__.file)
    |> Path.join(["fixtures/", file])
    |> File.read!()
    |> Jason.decode!()
  end
end
