defmodule WatchLater.Services.NewUploadsFinder do
  defp accounts_manager(), do: Application.get_env(:watch_later, :components)[:accounts_manager]
  defp youtube_api(), do: Application.get_env(:watch_later, :components)[:google_youtube_api]

  def discover_new_uploads(published_after) do
  end
end
