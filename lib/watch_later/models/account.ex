defmodule WatchLater.Models.Account do
  defstruct [:code, :role, :id, :name, :auth_token]

  @type role :: :watcher | :provider
  @type t :: %__MODULE__{code: String.t(), role: role}
end
