defmodule Blaine.Entities.Video do
  defstruct [:id, :title, :published_at, :channel]

  def filter(videos, filters) do
    Enum.reduce(filters, videos, &filter_by/2)
  end

  defp filter_by({:published_after, published_after}, videos) do
    Enum.filter(videos, fn %{published_at: published_at} ->
      DateTime.compare(published_at, published_after) == :gt
    end)
  end

  defp filter_by({:already_seen, already_seen}, videos) do
    Enum.reject(videos, fn %{id: id} ->
      already_seen |> MapSet.member?(id)
    end)
  end

  defp filter_by(_, videos), do: videos
end
