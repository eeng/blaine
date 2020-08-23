defmodule WatchLater.Google.PeopleAPI.Behaviour do
  alias WatchLater.Google.AuthToken

  @callback me(AuthToken.t()) :: {:ok, any} | {:error, any}
end

defmodule WatchLater.Google.PeopleAPI do
  @behaviour WatchLater.Google.PeopleAPI.Behaviour

  alias WatchLater.Google.AuthToken

  defp http(), do: Application.get_env(:watch_later, :components)[:http_client]

  def client(%AuthToken{access_token: access_token, token_type: token_type}) do
    http().client(
      base_url: "https://people.googleapis.com/v1",
      headers: [{"Authorization", "#{token_type} #{access_token}"}]
    )
  end

  @impl true
  def me(token) do
    client(token) |> http().get("/people/me", query: [personFields: "names"]) |> extract_profile()
  end

  defp extract_profile({:ok, %{"names" => names}}) do
    [%{"displayName" => name, "metadata" => %{"source" => %{"id" => id}}}] = names
    {:ok, %{id: id, name: name}}
  end

  defp extract_profile(response), do: response
end
