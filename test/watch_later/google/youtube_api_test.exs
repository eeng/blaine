defmodule WatchLater.Google.YouTubeAPITest do
  use ExUnit.Case, async: true

  alias WatchLater.Util.MockHTTP
  alias WatchLater.Google.YouTubeAPI
  alias WatchLater.Google.AuthToken

  import Mox
  setup :verify_on_exit!

  @token %AuthToken{}

  setup do
    MockHTTP |> stub(:client, fn _ -> :client end)
    :ok
  end

  describe "my_subscriptions" do
    test "should return the channel's id and title for each subscription" do
      response = fixture("youtube/list_subscriptions.json")
      q = [mine: true, part: "snippet", maxResults: 50]
      MockHTTP |> expect(:get, fn _, "/subscriptions", query: ^q -> {:ok, response} end)

      assert {:ok,
              [
                %{channel_id: "UCEBb1b_L6zDS3xTUrIALZOw", title: "MIT OpenCourseWare"},
                %{channel_id: "UC2DjFE7Xf11URZqWBigcVOQ", title: "EEVblog"}
              ]} = YouTubeAPI.my_subscriptions(@token)
    end

    test "when an error occours, should return it as is" do
      MockHTTP |> expect(:get, fn _, _, _ -> {:error, :unauthorized} end)
      assert {:error, :unauthorized} = YouTubeAPI.my_subscriptions(@token)
    end
  end

  describe "get_uploads_playlist_id" do
    test "should get the id of the uploads playlist for the channel" do
      response = fixture("youtube/list_channels.json")
      q = [id: "UC2DjFE7Xf11URZqWBigcVOQ", part: "contentDetails"]
      MockHTTP |> expect(:get, fn _, "/channels", query: ^q -> {:ok, response} end)

      assert {:ok, "UU_x5XG1OV2P6uZZ5FSM9Ttw"} =
               YouTubeAPI.get_uploads_playlist_id(@token, q[:id])
    end
  end

  describe "list_videos" do
    test "should find the id of the lastest videos in the playlist" do
      response = fixture("youtube/list_playlist_items.json")
      q = [playlistId: "UC_x5XG1OV2P6uZZ5FSM9Ttw", part: "snippet,contentDetails", maxResults: 50]
      MockHTTP |> expect(:get, fn _, "/playlistItems", query: ^q -> {:ok, response} end)

      assert {:ok,
              [
                %{
                  video_id: "DMfFnnrJ7xA",
                  published_at: ~U[2020-08-20 21:04:16Z],
                  title: "Android Beyond Phones, chromeos.dev, Go 1.15, and more!"
                },
                %{
                  video_id: "S0RiTTbhVBE",
                  published_at: ~U[2020-08-18T16:01:15Z],
                  title: "Join us for the Developer Student Clubs 2020 Solution Challenge!"
                }
              ]} = YouTubeAPI.list_videos(@token, q[:playlistId])
    end
  end

  describe "insert_video" do
    test "should send the correct request" do
      response = fixture("youtube/insert_video_ok.json")
      video_id = "M7FIvfx5J10"
      playlist_id = "WL"
      query = [part: "snippet"]

      body = %{
        snippet: %{
          playlistId: playlist_id,
          resourceId: %{kind: "youtube#video", videoId: video_id}
        }
      }

      MockHTTP
      |> expect(:post, fn _, "/playlistItems", body: ^body, query: ^query -> {:ok, response} end)

      assert :ok = YouTubeAPI.insert_video(@token, video_id, playlist_id)
    end

    test "if the video already exists in the playlist, should not be considered an error" do
      response = fixture("youtube/insert_video_already_exists.json")
      MockHTTP |> expect(:post, fn _, "/playlistItems", _ -> {:error, response} end)
      assert :ok = YouTubeAPI.insert_video(@token, "M7FIvfx5J10", "WL")
    end

    test "other errors are returned" do
      response = fixture("youtube/insert_video_unauthorized.json")
      MockHTTP |> expect(:post, fn _, "/playlistItems", _ -> {:error, response} end)

      assert {:error, %{"error" => %{"code" => 403}}} =
               YouTubeAPI.insert_video(@token, "M7FIvfx5J10", "WL")
    end
  end

  def fixture(file) do
    Path.join([__DIR__, "fixtures/", file])
    |> File.read!()
    |> Jason.decode!()
  end
end
