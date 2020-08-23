defmodule WatchLater.Google.Behaviours do
  alias WatchLater.Google.AuthToken

  defmodule AuthAPI do
    @callback get_token(String.t()) :: {:ok, %AuthToken{}} | {:error, any}
    @callback renew_token(%AuthToken{}) :: {:ok, %AuthToken{}} | {:error, any} | :still_valid
  end

  defmodule PeopleAPI do
    @callback me(%AuthToken{}) :: {:ok, any} | {:error, any}
  end

  defmodule YouTubeAPI do
    @callback my_subscriptions(%AuthToken{}) :: {:ok, [map]} | {:error, any}
    @callback get_uploads_playlist_id(%AuthToken{}, String.t()) ::
                {:ok, String.t()} | {:error, any}
    @callback list_videos(%AuthToken{}, String.t()) :: {:ok, String.t()} | {:error, any}
  end
end
