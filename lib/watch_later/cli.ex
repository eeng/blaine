defmodule WatchLater.CLI do
  alias WatchLater.{GoogleAuth, Marshal}

  @db_path "/tmp/watch_leter.db"

  def authorize do
    auth_url = GoogleAuth.authorize_url(scope: "https://www.googleapis.com/auth/youtube.readonly")
    IO.puts("Visit the following URL and copy the returned code:")
    IO.puts(auth_url <> "\n")

    code = IO.gets("Paste the code here: ") |> String.trim()
    GoogleAuth.get_token(code) |> store_token()
  end

  defp store_token({:ok, token} = result) do
    Marshal.dump(token, @db_path)
    result
  end

  defp store_token(result), do: result
end
