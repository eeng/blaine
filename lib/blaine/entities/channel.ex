defmodule Blaine.Entities.Channel do
  defstruct [:id, :name, :playlist_id]

  def filter_channels(channels, filters) do
    Enum.reduce(filters, channels, fn
      {:channel_ids, ids}, channels -> Enum.filter(channels, fn %{id: id} -> id in ids end)
      _, channels -> channels
    end)
  end
end
