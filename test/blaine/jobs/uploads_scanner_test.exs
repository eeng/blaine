defmodule Blaine.Jobs.UploadsScannerTest do
  use ExUnit.Case, async: true

  alias Blaine.Jobs.UploadsScanner
  alias Blaine.Services.MockUploadsService

  import Mox
  setup :verify_on_exit!

  describe "checkpoint execution" do
    test "calls the service with the last_run_at and then updates it", context do
      t1 = DateTime.utc_now()
      process_opts = [name: context.test, last_run_at: t1]
      scanner = start_supervised!({UploadsScanner, process_opts})

      expect_service_called(scanner, t1)
      send(scanner, :work)
      %{last_run_at: t2} = :sys.get_state(scanner)
      assert :gt = DateTime.compare(t2, t1)

      expect_service_called(scanner, t2)
      send(scanner, :work)
      %{last_run_at: t3} = :sys.get_state(scanner)
      assert :gt = DateTime.compare(t3, t2)
    end

    defp expect_service_called(scanner, published_after) do
      parent = self()

      MockUploadsService
      |> allow(parent, scanner)
      |> expect(:find_uploads_and_add_to_blaine, fn published_after: ^published_after ->
        {:ok, 0}
      end)
    end
  end
end
