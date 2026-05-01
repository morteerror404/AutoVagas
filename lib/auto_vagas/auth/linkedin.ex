defmodule AutoVagas.Auth.LinkedIn do
  @moduledoc """
  LinkedIn OAuth 2.0 OpenID Connect integration.
  Flow: Authorization Code Grant with OpenID Connect.
  """

  require Logger

  @linkedin_auth_url "https://www.linkedin.com/oauth/v2/authorization"
  @linkedin_token_url "https://www.linkedin.com/oauth/v2/accessToken"
  @linkedin_userinfo_url "https://api.linkedin.com/v2/userinfo"

  @doc """
  Returns the URL to redirect user for LinkedIn OAuth with OpenID Connect.
  """
  def authorize_url(state \\ "random_state") do
    client_id = get_client_id()
    redirect_uri = get_redirect_uri()

    query =
      URI.encode_query(%{
        response_type: "code",
        client_id: client_id,
        redirect_uri: redirect_uri,
        state: state,
        scope: "openid profile email"
      })

    "#{@linkedin_auth_url}?#{query}"
  end

  @doc """
  Exchanges authorization code for access token via OpenID Connect.
  """
  def exchange_code(code) do
    client_id = get_client_id()
    client_secret = get_client_secret()
    redirect_uri = get_redirect_uri()

    body =
      URI.encode_query(%{
        "grant_type" => "authorization_code",
        "code" => code,
        "redirect_uri" => redirect_uri,
        "client_id" => client_id,
        "client_secret" => client_secret
      })

    headers = [{"Content-Type", "application/x-www-form-urlencoded"}]

    case Req.post(@linkedin_token_url, body: body, headers: headers) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        token_data = Jason.decode!(body)
        access_token = token_data["access_token"]
        save_token(access_token)
        {:ok, token_data}

      {:ok, %Req.Response{status: status, body: body}} ->
        Logger.error("LinkedIn token exchange failed: #{status} - #{inspect(body)}")
        {:error, "Token exchange failed: #{inspect(body)}"}

      {:error, reason} ->
        Logger.error("LinkedIn token exchange error: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Fetches user profile from LinkedIn UserInfo endpoint (OpenID Connect).
  """
  def get_userinfo(token) do
    headers = [{"Authorization", "Bearer #{token}"}]

    case Req.get(@linkedin_userinfo_url, headers: headers) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %Req.Response{status: status, body: body}} ->
        Logger.error("LinkedIn userinfo fetch failed: #{status} - #{inspect(body)}")
        {:error, "Userinfo fetch failed"}

      {:error, reason} ->
        Logger.error("LinkedIn userinfo error: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp get_client_id do
    config = load_auth_config()
    get_in(config, ["linkedin", "client_id"]) || System.get_env("LINKEDIN_CLIENT_ID") || "77k7gf05ngamtq"
  end

  defp get_client_secret do
    config = load_auth_config()
    encrypted_secret = get_in(config, ["linkedin", "client_secret"]) || System.get_env("LINKEDIN_CLIENT_SECRET")

    if encrypted_secret && String.length(encrypted_secret) > 40 do
      try do
        AutoVagas.Auth.Crypto.decrypt(encrypted_secret)
      rescue
        _ -> encrypted_secret
      end
    else
      encrypted_secret
    end
  end

  defp get_redirect_uri do
    "https://localhost:4000/auth/linkedin/callback"
  end

  defp save_token(token) do
    config_path = "priv/filters/auth_config.json"
    config = load_auth_config()
    updated = put_in(config, ["linkedin", "access_token"], token)
    File.write!(config_path, Jason.encode!(updated, pretty: true))
  end

  defp load_auth_config do
    path = "priv/filters/auth_config.json"
    if File.exists?(path) do
      path |> File.read!() |> Jason.decode!()
    else
      %{}
    end
  end
end
