defmodule WatchLater.Google.Behaviours do
  alias WatchLater.Google.AuthToken

  defmodule AuthAPI do
    @callback get_token(String.t()) :: {:ok, %AuthToken{}} | {:error, any}
  end

  defmodule PeopleAPI do
    @callback client(%AuthToken{}) :: any
    @callback me(any, list) :: {:ok, any} | {:error, any}
  end
end
