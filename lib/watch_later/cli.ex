defmodule WatchLater.CLI do
  alias WatchLater.{GoogleAuth, Repository}

  def authorize do
    scopes = ~w(
      https://www.googleapis.com/auth/userinfo.profile
      https://www.googleapis.com/auth/youtube.readonly
    ) |> Enum.join(" ")
    auth_url = GoogleAuth.authorize_url(scope: scopes)
    IO.puts("Visit the following URL and copy the given code:\n")
    IO.puts(auth_url <> "\n")

    code = IO.gets("Then paste the code here: ") |> String.trim()
    GoogleAuth.get_token(code) |> store_token()
  end

  defp store_token({:ok, token} = result) do
    Repository.save_token(token)
    result
  end

  defp store_token(result), do: result
end
