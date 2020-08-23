defmodule WatchLater.Factory do
  alias WatchLater.Entities.{Account, Video}
  alias WatchLater.Google.AuthToken

  def build(:account) do
    %Account{id: to_string(sequence()), role: :both}
  end

  def build(:video) do
    %Video{id: to_string(sequence()), published_at: DateTime.utc_now()}
  end

  def build(:auth_token) do
    %AuthToken{access_token: "QuEWgBnoMGCM0O"}
  end

  def build(factory, quantity) when is_integer(quantity) do
    factory |> build(quantity, [])
  end

  def build(factory, attributes) when is_list(attributes) do
    factory |> build() |> struct(attributes)
  end

  def build(factory, quantity, attributes) do
    Enum.map(1..quantity, fn _ -> build(factory, attributes) end)
  end

  defp sequence do
    :erlang.unique_integer([:positive, :monotonic])
  end
end
