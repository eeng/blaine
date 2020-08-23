defmodule WatchLater.Google.PeopleAPITest do
  use ExUnit.Case, async: true

  alias WatchLater.Util.MockHTTP
  alias WatchLater.Google.PeopleAPI
  alias WatchLater.Google.AuthToken

  import Mox
  setup :verify_on_exit!

  @token %AuthToken{}

  setup do
    MockHTTP |> stub(:client, fn _ -> :client end)
    :ok
  end

  describe "me" do
    test "returns the user's id and name" do
      response = fixture("people/me.json")
      q = [personFields: "names"]
      MockHTTP |> expect(:get, fn _, "/people/me", query: ^q -> {:ok, response} end)
      assert {:ok, %{id: "104589733694719471688", name: "Max Payne"}} = PeopleAPI.me(@token)
    end

    test "when an error occours, should return it as is" do
      MockHTTP |> expect(:get, fn _, "/people/me", query: _ -> {:error, :unauthorized} end)
      assert {:error, :unauthorized} = PeopleAPI.me(@token)
    end
  end

  def fixture(file) do
    Path.join([__DIR__, "fixtures/", file])
    |> File.read!()
    |> Jason.decode!()
  end
end
