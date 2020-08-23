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
    test "should return the id of the uploads playlist for the channel" do
      response = fixture("youtube/list_channels.json")
      q = [id: "UC_x5XG1OV2P6uZZ5FSM9Ttw", part: "contentDetails"]
      MockHTTP |> expect(:get, fn _, "/channels", query: ^q -> {:ok, response} end)

      assert {:ok, "UU_x5XG1OV2P6uZZ5FSM9Ttw"} =
               YouTubeAPI.get_uploads_playlist_id(@token, q[:id])
    end
  end

  def fixture(file) do
    Path.join([__DIR__, "fixtures/", file])
    |> File.read!()
    |> Jason.decode!()
  end
end
