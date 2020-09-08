defmodule Blaine.Entities.VideoTest do
  use ExUnit.Case, async: true

  alias Blaine.Entities.Video
  import Blaine.Factory

  describe "filter" do
    test "allows to filter by published_after" do
      v1 = build(:video, published_at: ~U[2020-07-15 00:00:00Z])
      v2 = build(:video, published_at: ~U[2020-07-17 00:00:00Z])

      assert [v2] = Video.filter([v1, v2], published_after: ~U[2020-07-16 00:00:00Z])
    end

    test "already_seen" do
      v1 = build(:video)
      v2 = build(:video)

      assert [v1] = Video.filter([v1, v2], already_seen: MapSet.new([v2.id]))
    end
  end
end
