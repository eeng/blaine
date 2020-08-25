defmodule Blaine.Entities.VideoTest do
  use ExUnit.Case, async: true

  alias Blaine.Entities.Video
  import Blaine.Factory

  describe "filter_and_sort" do
    test "allows to filter by published_after" do
      v1 = build(:video, published_at: ~U[2020-07-15 00:00:00Z])
      v2 = build(:video, published_at: ~U[2020-07-17 00:00:00Z])

      assert [v2] = Video.filter_and_sort([v1, v2], published_after: ~U[2020-07-16 00:00:00Z])
    end
  end
end
