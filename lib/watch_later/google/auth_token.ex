defmodule WatchLater.Google.AuthToken do
  defstruct [:access_token, :refresh_token, :token_type, :generated_at, :expires_at]

  alias __MODULE__
  alias WatchLater.Clock

  def from_json(json, clock \\ Clock.Real) do
    generated_at = clock.current_timestamp()

    %AuthToken{
      access_token: json["access_token"],
      refresh_token: json["refresh_token"],
      token_type: json["token_type"],
      generated_at: generated_at,
      expires_at: generated_at + json["expires_in"]
    }
  end
end
