defmodule WatchLater.Repository do
  alias WatchLater.Marshal

  @db_path "/tmp/watch_leter.db"

  def save_token(token) do
    Marshal.dump(token, @db_path)
  end

  def load_token do
    Marshal.load(@db_path)
  end
end
