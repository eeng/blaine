defmodule Blaine.Entities.Account do
  defstruct [:id, :name, :role, :email, :auth_token, :code, :add_to_playlist_id]

  alias __MODULE__

  @type role :: :watcher | :provider | :both
  @type t :: %Account{
          code: String.t(),
          role: role,
          id: String.t(),
          add_to_playlist_id: String.t()
        }

  def build(fields) do
    account = struct(Account, fields)

    case validate(account) do
      :ok -> {:ok, account}
      error -> {:error, error}
    end
  end

  defp validate(%{role: role}) when role not in [:watcher, :provider, :both], do: :missing_role

  defp validate(%{role: role, add_to_playlist_id: playlist_id})
       when role in [:watcher, :both] and is_nil(playlist_id),
       do: :missing_add_to_playlist_id

  defp validate(_), do: :ok
end
