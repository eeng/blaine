defmodule WatchLater.AuthToken do
  defstruct [:access_token, :expires_in, :expires_at, :refresh_token, :token_type]

  alias WatchLater.Clock

  def new(args, clock \\ Clock.Real) do
    ExConstructor.populate_struct(%__MODULE__{}, args) |> calculate_expires_at(clock)
  end

  defp calculate_expires_at(%{expires_in: expires_in} = token, clock) do
    %{token | expires_at: clock.current_timestamp() + expires_in}
  end
end
