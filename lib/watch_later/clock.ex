defmodule WatchLater.Clock do
  @callback current_timestamp() :: integer()
end

defmodule WatchLater.Clock.Real do
  @behaviour WatchLater.Clock

  def current_timestamp() do
    :os.system_time(:second)
  end
end
