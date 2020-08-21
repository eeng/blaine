defmodule WatchLater.Google.Behaviours do
  alias WatchLater.Google.AuthToken

  defmodule AuthAPI do
    @callback get_token(String.t()) :: {:ok, %AuthToken{}} | {:error, any}
    @callback renew_token(%AuthToken{}) :: {:ok, %AuthToken{}} | {:error, any}
  end

  defmodule PeopleAPI do
    @callback me(%AuthToken{}, list) :: {:ok, any} | {:error, any}
  end
end
