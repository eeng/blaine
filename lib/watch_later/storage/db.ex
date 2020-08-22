defmodule WatchLater.Storage.DB do
  @type db :: atom

  @dets_table Application.get_env(:watch_later, __MODULE__)[:dets_table]

  @spec open(db) :: {:ok, any} | {:error, any}
  def open(db \\ @dets_table) do
    :dets.open_file(db, [{:file, db_file(db)}])
  end

  @spec close(db) :: :ok | {:error, any}
  def close(db) do
    :dets.close(db)
  end

  @spec store(db, atom, any) :: :ok | {:error, any}
  def store(db, key, value) do
    :dets.insert(db, {key, value})
  end

  @spec fetch(db, atom) :: {:ok, any} | {:error, any}
  def fetch(db, key) do
    case :dets.lookup(db, key) do
      [{^key, value}] -> {:ok, value}
      _ -> {:error, :not_found}
    end
  end

  def destroy(db) do
    :dets.delete_all_objects(db)
    File.rm(db_file(db))
  end

  defp db_file(db) do
    "#{db}.db" |> String.to_charlist()
  end
end
