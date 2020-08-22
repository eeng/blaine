defmodule WatchLater.Util.HTTP.Behaviour do
  @callback client(list) :: struct
  @callback get(struct, String.t(), list) :: {:ok, any} | {:error, any}
  @callback post(struct, String.t(), list) :: {:ok, any} | {:error, any}
end

defmodule WatchLater.Util.HTTP do
  @behaviour WatchLater.Util.HTTP.Behaviour

  defstruct base_url: "", headers: [], format: :json

  alias __MODULE__

  @impl true
  def client(opts \\ []) do
    struct(HTTP, opts)
  end

  @impl true
  def get(client, url, opts \\ []) do
    request(client, :get, url, opts)
  end

  @impl true
  def post(client, url, opts \\ []) do
    request(client, :post, url, opts)
  end

  def request(client, method, url, opts) do
    opts = Keyword.merge([method: method, url: url], opts)

    Tesla.client(middleware(client))
    |> Tesla.request(opts)
    |> handle_response()
  end

  defp middleware(%HTTP{base_url: base_url, headers: headers, format: format}) do
    [
      {Tesla.Middleware.BaseUrl, base_url},
      {Tesla.Middleware.Headers, headers}
    ] ++
      format_middleware(format) ++
      [Tesla.Middleware.Logger]
  end

  defp format_middleware(:json) do
    [Tesla.Middleware.JSON]
  end

  defp format_middleware(:form_request_json_response) do
    [Tesla.Middleware.FormUrlencoded, Tesla.Middleware.DecodeJson]
  end

  defp handle_response(response) do
    case response do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, %{body: body}} -> {:error, body}
      error -> error
    end
  end
end
