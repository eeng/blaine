defmodule WatchLater.Google.AuthTokenTest do
  use ExUnit.Case, async: true

  alias WatchLater.MockClock
  alias WatchLater.Google.AuthToken

  import Mox
  setup :verify_on_exit!

  describe "from_json" do
    test "calculates the correct expires_at based on expires_in" do
      MockClock |> expect(:current_timestamp, fn -> 1_597_969_146 end)

      assert %AuthToken{expires_at: 1_597_972_745} =
               AuthToken.from_json(%{"expires_in" => 3599}, MockClock)
    end
  end
end
