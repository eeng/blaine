defmodule WatchLater.Services.AccountsManager do
  use GenServer
  alias WatchLater.Models.Account

  @me __MODULE__

  def start_link(opts) do
    name = Keyword.get(opts, :name, @me)
    GenServer.start_link(@me, [], name: name)
  end

  def stop(manager) do
    GenServer.stop(manager)
  end

  @spec add_account(atom(), String.t(), Account.role()) :: Account.t()
  def add_account(manager \\ @me, code, role) do
    GenServer.call(manager, {:add_account, code, role})
  end

  @spec accounts(atom(), Account.role() | :all) :: [Account.t()]
  def accounts(manager \\ @me, role \\ :all) do
    GenServer.call(manager, {:get_accounts, role})
  end

  @impl true
  def init(accounts) do
    {:ok, accounts}
  end

  @impl true
  def handle_call({:add_account, code, role}, _from, accounts) do
    with {:ok, token} <- auth_api().get_token(code),
         {id, name} <- fetch_profile(token) do
      account = %Account{code: code, role: role, auth_token: token, id: id, name: name}
      {:reply, {:ok, account}, [account | accounts]}
    else
      error ->
        {:reply, error, accounts}
    end
  end

  @impl true
  def handle_call({:get_accounts, role}, _from, accounts) do
    filtered = Enum.filter(accounts, &role_matches?(&1, role))
    {:reply, filtered, accounts}
  end

  defp fetch_profile(token) do
    people_api().me(token, personFields: "names") |> extract_profile()
  end

  defp extract_profile({:ok, profile}) do
    %{
      "names" => [
        %{"displayName" => name, "metadata" => %{"source" => %{"id" => id}}}
      ]
    } = profile

    {id, name}
  end

  defp role_matches?(_, :all), do: true
  defp role_matches?(%Account{role: role}, role), do: true
  defp role_matches?(_, _), do: false

  defp auth_api(), do: Application.get_env(:watch_later, :google_auth_api)
  defp people_api(), do: Application.get_env(:watch_later, :google_people_api)
end
