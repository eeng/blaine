defmodule Blaine.Entities.Account do
  defstruct [:id, :name, :role, :email, :auth_token, :code]

  alias __MODULE__

  @type role :: :watcher | :provider | :both
  @type t :: %Account{code: String.t(), role: role, id: String.t()}
end
