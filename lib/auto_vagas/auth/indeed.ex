defmodule AutoVagas.Auth.Indeed do
  @moduledoc """
  Indeed OAuth 2.0 / SSO integration.
  Supports both candidate and employer flows.
  """

  require Logger

  @indeed_auth_url "https://accounts.indeed.com/oauth/v2/authorize"
  @indeed_token_url "https://accounts.indeed.com/oauth/v2/token"

  @doc """
  Returns the URL to redirect user for Indeed OAuth.
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
        scope: "r_emailaddress r_basicprofile"
      })

    "#{@indeed_auth_url}?#{query}"
  end

  @doc """
  Exchanges authorization code for access token.
  """
  def exchange_code(code) do
    client_id = get_client_id()
    client_secret = get_client_secret()
    redirect_uri = get_redirect_uri()

    body =
      URI.encode_query(%{
        grant_type: "authorization_code",
        code: code,
        redirect_uri: redirect_uri,
        client_id: client_id,
        client_secret: client_secret
      })

    headers = [{"Content-Type", "application/x-www-form-urlencoded"}]

    case Req.post(@indeed_token_url, body: body, headers: headers) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        token_data = Jason.decode!(body)
        access_token = token_data["access_token"]
        save_token(access_token)
        {:ok, access_token}

      {:ok, %Req.Response{status: status, body: body}} ->
        Logger.error("Indeed token exchange failed: #{status} - #{body}")
        {:error, "Token exchange failed"}

      {:error, reason} ->
        Logger.error("Indeed token exchange error: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Fetches user profile from Indeed API.
  """
  def get_profile(token) do
    headers = [{"Authorization", "Bearer #{token}"}]

    case Req.get("https://apis.indeed.com/v2/auth/userinfo", headers: headers) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %Req.Response{status: status, body: body}} ->
        Logger.error("Indeed profile fetch failed: #{status} - #{body}")
        {:error, "Profile fetch failed"}

      {:error, reason} ->
        Logger.error("Indeed profile error: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp get_client_id do
    config = load_auth_config()
    get_in(config, ["indeed", "client_id"]) || System.get_env("INDEED_CLIENT_ID")
  end

  defp get_client_secret do
    config = load_auth_config()
    encrypted_secret = get_in(config, ["indeed", "client_secret"]) || System.get_env("INDEED_CLIENT_SECRET")

    if encrypted_secret && String.length(encrypted_secret) > 40 do
      # Assume it's encrypted (Base64 encoded ciphertext is longer)
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
    System.get_env("INDEED_REDIRECT_URI") ||
      "https://localhost:4000/auth/auth/indeed/callback"
  end

  defp save_token(token) do
    config_path = "priv/filters/auth_config.json"
    config = load_auth_config()
    updated = put_in(config, ["indeed", "access_token"], token)
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
