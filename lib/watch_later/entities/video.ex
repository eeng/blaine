defmodule WatchLater.Entities.Video do
  defstruct [:id, :title, :published_at, :channel]

  def filter_and_sort(videos, opts) do
    videos = videos |> Enum.sort_by(& &1.published_at, DateTime)
    Enum.reduce(opts, videos, &filter_by/2)
  end

  defp filter_by({:published_after, published_after}, videos) do
    videos
    |> Enum.filter(fn %{published_at: published_at} ->
      DateTime.compare(published_at, published_after) == :gt
    end)
  end

  defp filter_by(_, videos), do: videos
end
