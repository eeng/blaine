defmodule Blaine.Google.PeopleAPI.Behaviour do
  alias Blaine.Google.AuthToken

  @callback me(AuthToken.t()) :: {:ok, any} | {:error, any}
end

defmodule Blaine.Google.PeopleAPI do
  @behaviour Blaine.Google.PeopleAPI.Behaviour

  alias Blaine.Google.AuthToken

  defp http(), do: Application.get_env(:blaine, :components)[:http_client]

  def client(%AuthToken{access_token: access_token, token_type: token_type}) do
    http().client(
      base_url: "https://people.googleapis.com/v1",
      headers: [{"Authorization", "#{token_type} #{access_token}"}]
    )
  end

  @impl true
  def me(token) do
    client(token)
    |> http().get("/people/me", query: [personFields: "names,emailAddresses"])
    |> extract_profile()
  end

  defp extract_profile({:ok, %{"names" => names, "emailAddresses" => emails}}) do
    [%{"displayName" => name, "metadata" => %{"source" => %{"id" => id}}}] = names
    [%{"value" => email}] = emails
    {:ok, %{id: id, name: name, email: email}}
  end

  defp extract_profile(response), do: response
end
