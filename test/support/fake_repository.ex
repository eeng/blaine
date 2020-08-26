defmodule Blaine.FakeRepository do
  @behaviour Blaine.Persistance.Repository

  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @impl true
  def last_run_at() do
    Agent.get(__MODULE__, &Map.get(&1, :last_run_at))
  end

  @impl true
  def save_last_run_at(last_run_at) do
    Agent.update(__MODULE__, &Map.put(&1, :last_run_at, last_run_at))
  end

  defmacro __using__(_opts) do
    quote do
      alias Blaine.FakeRepository

      setup do
        start_supervised!(FakeRepository)
        :ok
      end
    end
  end
end
