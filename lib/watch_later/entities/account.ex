defmodule WatchLater.Entities.Account do
  defstruct [:code, :role, :id, :name, :auth_token]

  alias __MODULE__

  @type role :: :watcher | :provider | :both
  @type t :: %Account{code: String.t(), role: role}
end
