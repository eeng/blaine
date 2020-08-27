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

      expect_service_called(t1)
      send(scanner, :work)
      %{last_run_at: t2} = :sys.get_state(scanner)
      assert :gt = DateTime.compare(t2, t1)

      expect_service_called(t2)
      send(scanner, :work)
      %{last_run_at: t3} = :sys.get_state(scanner)
      assert :gt = DateTime.compare(t3, t2)
    end

    defp expect_service_called(published_after) do
      MockUploadsService
      |> expect(:find_uploads_and_add_to_watch_later, fn published_after: ^published_after ->
        {:ok, 0}
      end)
    end
  end
end
