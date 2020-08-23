defmodule WatchLater.Services.NewUploadsFinderTest do
  use ExUnit.Case, async: true

  import Mox
  import WatchLater.Factory
  alias WatchLater.Services.NewUploadsFinder
  alias WatchLater.Google.MockYouTubeAPI
  alias WatchLater.Entities.Video

  setup :verify_on_exit!

  @token build(:auth_token)

  describe "find_new_uploads_for_account" do
    test "should query the correct YouTube API endpoints" do
      account = build(:account, auth_token: @token)

      subscriptions = [%{channel_id: "ch1"}, %{channel_id: "ch2"}]

      videos_ch1 = [
        %{video_id: "v1", published_at: ~U[2020-07-15 00:00:00Z]},
        %{video_id: "v2", published_at: ~U[2020-07-16 00:00:00Z]}
      ]

      videos_ch2 = [%{video_id: "v3", published_at: ~U[2020-07-17 00:00:00Z]}]

      MockYouTubeAPI
      |> expect(:my_subscriptions, fn @token -> {:ok, subscriptions} end)
      |> expect(:get_uploads_playlist_id, fn @token, "ch1" -> {:ok, "pl1"} end)
      |> expect(:get_uploads_playlist_id, fn @token, "ch2" -> {:ok, "pl2"} end)
      |> expect(:list_videos, fn @token, "pl1" -> {:ok, videos_ch1} end)
      |> expect(:list_videos, fn @token, "pl2" -> {:ok, videos_ch2} end)

      assert [%Video{id: "v3"}, %Video{id: "v2"}, %Video{id: "v1"}] =
               NewUploadsFinder.find_new_uploads_for_account(account)
    end
  end

  describe "filter_and_sort_videos" do
    test "allows to filter by published_after" do
      v1 = build(:video, published_at: ~U[2020-07-15 00:00:00Z])
      v2 = build(:video, published_at: ~U[2020-07-17 00:00:00Z])

      assert [v2] =
               NewUploadsFinder.filter_and_sort_videos([v1, v2],
                 published_after: ~U[2020-07-16 00:00:00Z]
               )
    end
  end
end
