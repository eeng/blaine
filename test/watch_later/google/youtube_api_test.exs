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

  describe "list_subscriptions" do
    test "should return the channel's id and title for each subscription" do
      response = fixture("youtube/list_subscriptions.json")
      q = [mine: true, part: "snippet", maxResults: 50]
      MockHTTP |> expect(:get, fn _, "/subscriptions", query: ^q -> {:ok, response} end)

      assert [
               %{channel_id: "UCEBb1b_L6zDS3xTUrIALZOw", title: "MIT OpenCourseWare"},
               %{channel_id: "UC2DjFE7Xf11URZqWBigcVOQ", title: "EEVblog"}
             ] = YouTubeAPI.list_subscriptions(@token)
    end
  end

  def fixture(file) do
    Path.dirname(__ENV__.file)
    |> Path.join(["fixtures/", file])
    |> File.read!()
    |> Jason.decode!()
  end
end
