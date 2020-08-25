defmodule Blaine.Util.Clock.Behaviour do
  @callback current_timestamp() :: integer()
end

defmodule Blaine.Util.Clock do
  @behaviour Blaine.Util.Clock.Behaviour

  def current_timestamp() do
    :os.system_time(:second)
  end
end
