defmodule WatchLater.Util.Clock.Behaviour do
  @callback current_timestamp() :: integer()
end

defmodule WatchLater.Util.Clock do
  @behaviour WatchLater.Util.Clock.Behaviour

  def current_timestamp() do
    :os.system_time(:second)
  end
end
