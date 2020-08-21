defmodule WatchLater.Util.Clock do
  @callback current_timestamp() :: integer()
end

defmodule WatchLater.Util.Clock.Real do
  @behaviour WatchLater.Util.Clock

  def current_timestamp() do
    :os.system_time(:second)
  end
end
