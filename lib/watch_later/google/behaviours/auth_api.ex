defmodule WatchLater.Google.Behaviours.AuthAPI do
  alias WatchLater.Google.AuthToken

  @callback get_token(String.t()) :: {:ok, %AuthToken{}}
end
