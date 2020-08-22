defmodule WatchLater.Google.AuthToken do
  defstruct [:access_token, :refresh_token, :token_type, :generated_at, :expires_at]

  alias __MODULE__
  alias WatchLater.Util.Clock

  def from_json(json, clock \\ Clock) do
    generated_at = clock.current_timestamp()

    %AuthToken{
      access_token: json["access_token"],
      refresh_token: json["refresh_token"],
      token_type: json["token_type"],
      generated_at: generated_at,
      expires_at: generated_at + json["expires_in"]
    }
  end

  def must_renew?(%AuthToken{expires_at: expires_at}, clock \\ Clock) do
    clock.current_timestamp() > expires_at - 30
  end
end
