defmodule Blaine.Jobs.UploadsScannerTest do
  use ExUnit.Case
  use Blaine.Mocks

  alias Blaine.Jobs.UploadsScanner
  alias Blaine.Services.MockUploadsService
  alias Blaine.Persistance.MockRepository

  describe "checkpoint execution" do
    test "calls the service with the last_run_at and then updates it" do
      t1 = DateTime.utc_now()

      MockRepository
      |> expect(:last_run_at, fn -> t1 end)
      |> expect(:save_last_run_at, 2, fn _ -> :ok end)

      scanner = start_supervised!(UploadsScanner)

      expect_service_called_with(t1)
      send(scanner, :work)
      %{last_run_at: t2} = :sys.get_state(scanner)
      assert :gt = DateTime.compare(t2, t1)

      expect_service_called_with(t2)
      send(scanner, :work)
      %{last_run_at: t3} = :sys.get_state(scanner)
      assert :gt = DateTime.compare(t3, t2)
    end

    defp expect_service_called_with(published_after) do
      MockUploadsService
      |> expect(:find_uploads_and_add_to_watch_later, fn published_after: ^published_after ->
        {:ok, 0}
      end)
    end

    @tag capture_log: true
    test "if the service returns an error, it should crash (that way it'll be restarted and continue where it left off)" do
      MockRepository
      |> expect(:last_run_at, fn -> nil end)
      |> expect(:save_last_run_at, 0, fn _ -> :ok end)

      MockUploadsService
      |> expect(:find_uploads_and_add_to_watch_later, fn _ -> {:error, "oops"} end)

      scanner = start_supervised!(UploadsScanner)

      ref = Process.monitor(scanner)
      send(scanner, :work)
      assert_receive {:DOWN, ^ref, _, ^scanner, _}
    end
  end
end
