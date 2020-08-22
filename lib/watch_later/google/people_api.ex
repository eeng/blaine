defmodule WatchLater.Google.PeopleAPI do
  @behaviour WatchLater.Google.Behaviours.PeopleAPI

  alias WatchLater.Google.AuthToken
  alias WatchLater.Util.HTTP

  def client(%AuthToken{access_token: access_token, token_type: token_type}) do
    HTTP.client(
      base_url: "https://people.googleapis.com/v1",
      headers: [{"Authorization", "#{token_type} #{access_token}"}]
    )
  end

  # Requires scope https://www.googleapis.com/auth/userinfo.profile
  @impl true
  def me(token) do
    client(token) |> HTTP.get("/people/me", query: [personFields: "names"]) |> extract_profile()
  end

  defp extract_profile({:ok, profile}) do
    %{
      "names" => [
        %{"displayName" => name, "metadata" => %{"source" => %{"id" => id}}}
      ]
    } = profile

    {:ok, %{id: id, name: name}}
  end
end
