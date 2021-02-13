defmodule Blaine.Services.UploadsServiceTest do
  use ExUnit.Case, async: true
  use Blaine.Mocks

  import Blaine.Factory

  alias Blaine.Services.{UploadsService, MockAccountsManager}
  alias Blaine.Google.MockYouTubeAPI
  alias Blaine.Entities.{Video, Channel}

  @token build(:auth_token)

  setup do
    %{account: build(:account, auth_token: @token, add_to_playlist_id: "WL")}
  end

  describe "find_uploads_for_account" do
    test "should query the correct YouTube API endpoints and return the found videos", %{
      account: account
    } do
      subscriptions = [%{channel_id: "ch1", title: "C1"}, %{channel_id: "ch2", title: "C2"}]

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

      # Added max_concurrency: 1 because Mox doesn't support expecting in any order
      # (the two :get_uploads_playlist_id could be called in a different order)
      assert [
               %Video{id: "v1", channel: %Channel{name: "C1", playlist_id: "pl1"}},
               %Video{id: "v2", channel: %Channel{name: "C1", playlist_id: "pl1"}},
               %Video{id: "v3", channel: %Channel{name: "C2", playlist_id: "pl2"}}
             ] = UploadsService.find_uploads_for_account(account, max_concurrency: 1)
    end

    test "allows to query only certain channels", %{account: account} do
      subscriptions = [%{channel_id: "ch1", title: "C1"}, %{channel_id: "ch2", title: "C2"}]

      MockYouTubeAPI
      |> expect(:my_subscriptions, fn @token -> {:ok, subscriptions} end)
      |> expect(:get_uploads_playlist_id, fn @token, "ch1" -> {:ok, "pl1"} end)
      |> expect(:list_videos, fn @token, "pl1" -> {:ok, []} end)

      UploadsService.find_uploads_for_account(account, channel_ids: ["ch1"])
    end
  end

  describe "add_videos_to_playlist" do
    test "should call the API with the watcher account's token, and return the results", %{
      account: account
    } do
      v1 = build(:video, id: "v1")
      v2 = build(:video, id: "v2")

      MockAccountsManager |> expect(:accounts, fn :watcher -> [account] end)

      MockYouTubeAPI
      |> expect(:insert_video, fn @token, "v1", "WL" -> :ok end)
      |> expect(:insert_video, fn @token, "v2", "WL" -> :ok end)

      assert [{v1, :ok}, {v2, :ok}] = UploadsService.add_videos_to_playlist([v1, v2])
    end

    test "if a video already exists in playlist, should indicate that in the result", %{
      account: account
    } do
      v = build(:video)

      MockAccountsManager |> expect(:accounts, fn :watcher -> [account] end)

      MockYouTubeAPI
      |> expect(:insert_video, fn @token, _, _ -> {:error, :already_in_playlist} end)

      assert [{v1, {:error, :already_in_playlist}}] = UploadsService.add_videos_to_playlist([v])
    end

    test "when there is an unexpected error, it should crash", %{account: account} do
      v = build(:video)
      MockAccountsManager |> expect(:accounts, fn :watcher -> [account] end)

      MockYouTubeAPI
      |> expect(:insert_video, fn @token, _, _ -> {:error, %{"error" => %{"code" => 400}}} end)

      assert_raise RuntimeError, ~r/error when uploading video/, fn ->
        UploadsService.add_videos_to_playlist([v])
      end
    end
  end
end
