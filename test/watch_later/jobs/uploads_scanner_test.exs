defmodule WatchLater.Jobs.UploadsScannerTest do
  use ExUnit.Case, async: true

  alias WatchLater.Jobs.UploadsScanner
  alias WatchLater.Services.MockUploadsService

  import Mox
  setup :verify_on_exit!

  describe "periodic execution" do
    test "calls the service with the last_published_after and then updates it", context do
      t1 = DateTime.utc_now()
      process_opts = [name: context.test, run_every: 10, last_published_after: t1]
      scanner = start_supervised!({UploadsScanner, process_opts})

      wait_until_service_is_called(scanner, t1)
      %{last_published_after: t2} = :sys.get_state(scanner)
      assert :gt = DateTime.compare(t2, t1)

      wait_until_service_is_called(scanner, t2)
      %{last_published_after: t3} = :sys.get_state(scanner)
      assert :gt = DateTime.compare(t3, t2)
    end

    defp wait_until_service_is_called(scanner, published_after) do
      parent = self()
      ref = make_ref()

      MockUploadsService
      |> allow(parent, scanner)
      |> expect(:find_uploads_and_add_to_watch_later, fn published_after: ^published_after ->
        send(parent, ref)
        {:ok, 0}
      end)

      assert_receive ^ref
    end
  end
end
