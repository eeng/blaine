defmodule Blaine.Google.AuthTokenTest do
  use ExUnit.Case, async: true
  use Blaine.Mocks

  alias Blaine.MockClock
  alias Blaine.Google.AuthToken

  describe "from_json" do
    test "calculates the correct expires_at based on expires_in" do
      MockClock |> expect(:current_timestamp, fn -> 1_597_969_146 end)

      assert %AuthToken{expires_at: 1_597_972_745} =
               AuthToken.from_json(%{"expires_in" => 3599}, MockClock)
    end
  end

  describe "must_renew?" do
    test "the token should be renewed a few seconds before the expiration" do
      now = 1_598_127_159
      MockClock |> stub(:current_timestamp, fn -> now end)
      assert AuthToken.must_renew?(%AuthToken{expires_at: now + 59}, MockClock)
      refute AuthToken.must_renew?(%AuthToken{expires_at: now + 61}, MockClock)
    end
  end
end
