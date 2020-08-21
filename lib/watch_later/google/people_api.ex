defmodule WatchLater.Google.PeopleAPI do
  @behaviour WatchLater.Google.Behaviours.PeopleAPI

  alias WatchLater.Google.AuthToken
  alias WatchLater.Util.HTTP

  defp client(%AuthToken{access_token: access_token, token_type: token_type}) do
    HTTP.client(
      base_url: "https://people.googleapis.com/v1",
      headers: [{"Authorization", "#{token_type} #{access_token}"}]
    )
  end

  # Requires scope https://www.googleapis.com/auth/userinfo.profile
  @impl true
  def me(token, params \\ []) do
    client(token) |> HTTP.get("/people/me", query: params)
  end
end
