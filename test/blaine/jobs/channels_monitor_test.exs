defmodule Blaine.Jobs.ChannelsMonitorTest do
  use ExUnit.Case
  use Blaine.Mocks

  import Blaine.Factory

  alias Blaine.Jobs.ChannelsMonitor
  alias Blaine.Services.MockUploadsService
  alias Blaine.Persistance.MockRepository

  setup context do
    if context[:stub_repo] do
      MockRepository
      |> stub(:last_run_at, fn -> nil end)
      |> stub(:save_last_run_at, fn _ -> :ok end)
    end

    :ok
  end

  describe "checkpoint execution" do
    test "calls the service with the last_run_at and then updates it" do
      t1 = DateTime.utc_now()

      MockRepository
      |> expect(:last_run_at, fn -> t1 end)
      |> expect(:save_last_run_at, 2, fn _ -> :ok end)

      monitor = start_supervised!(ChannelsMonitor)

      expect_service_called_with(t1)
      send(monitor, :work)
      %{last_run_at: t2} = :sys.get_state(monitor)
      assert :gt = DateTime.compare(t2, t1)

      expect_service_called_with(t2)
      send(monitor, :work)
      %{last_run_at: t3} = :sys.get_state(monitor)
      assert :gt = DateTime.compare(t3, t2)
    end

    defp expect_service_called_with(published_after) do
      MockUploadsService
      |> expect(:find_uploads_and_add_to_watch_later, fn opts ->
        an_hour_before = DateTime.add(published_after, -3600, :second)
        assert Keyword.get(opts, :published_after) == an_hour_before
        assert Keyword.get(opts, :already_seen) == MapSet.new()
        []
      end)
    end

    @tag :stub_repo
    test "should keep a set with the seen videos" do
      [v1, v2] = build(:video, 2)

      MockUploadsService
      |> expect(:find_uploads_and_add_to_watch_later, fn _ ->
        [{v1, :ok}, {v2, {:error, :already_in_playlist}}]
      end)

      monitor = start_supervised!(ChannelsMonitor)
      send(monitor, :work)
      assert :sys.get_state(monitor).seen_videos == MapSet.new([v1.id, v2.id])
    end

    @tag :capture_log
    test "if the service returns an error, it should crash (that way it'll be restarted and continue where it left off)" do
      MockRepository
      |> expect(:last_run_at, fn -> nil end)
      |> expect(:save_last_run_at, 0, fn _ -> :ok end)

      MockUploadsService
      |> expect(:find_uploads_and_add_to_watch_later, fn _ ->
        raise "oops"
      end)

      monitor = start_supervised!(ChannelsMonitor)

      ref = Process.monitor(monitor)
      send(monitor, :work)
      assert_receive {:DOWN, ^ref, _, ^monitor, _}
      refute Process.info(monitor)
    end
  end
end
