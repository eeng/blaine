defmodule WatchLater.Google do
  @config Application.fetch_env!(:watch_later, WatchLater.Google)

  def client do
    OAuth2.Client.new(
      strategy: OAuth2.Strategy.AuthCode,
      client_id: Keyword.get(@config, :google_client_id),
      client_secret: Keyword.get(@config, :google_client_secret),
      redirect_uri: "urn:ietf:wg:oauth:2.0:oob",
      site: "https://accounts.google.com",
      authorize_url: "/o/oauth2/auth",
      token_url: "/o/oauth2/token"
    )
    |> OAuth2.Client.put_serializer("application/json", Jason)
  end

  def authorize_url(params) do
    OAuth2.Client.authorize_url!(client(), params)
  end

  def get_token(params) do
    OAuth2.Client.get_token(client(), params)
  end
end
