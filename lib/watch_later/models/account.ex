defmodule WatchLater.Models.Account do
  defstruct [:code, :role]

  @type role :: :watcher | :provider
  @type t :: %__MODULE__{code: String.t(), role: role}
end
