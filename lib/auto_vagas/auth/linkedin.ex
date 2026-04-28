defmodule AutoVagas.Auth.LinkedIn do
  @moduledoc """
  LinkedIn OAuth 2.0 integration.
  Flow: Authorization Code Grant with PKCE.
  """

  require Logger

  @linkedin_auth_url "https://www.linkedin.com/oauth/v2/authorization"
  @linkedin_token_url "https://www.linkedin.com/oauth/v2/accessToken"
  @linkedin_api_url "https://api.linkedin.com/v2"

  @doc """
  Returns the URL to redirect user for LinkedIn OAuth.
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
        scope: "r_liteprofile r_emailaddress"
      })

    "#{@linkedin_auth_url}?#{query}"
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
        {:ok, access_token}

      {:ok, %Req.Response{status: status, body: body}} ->
        Logger.error("LinkedIn token exchange failed: #{status} - #{body}")
        {:error, "Token exchange failed: #{body}"}

      {:error, reason} ->
        Logger.error("LinkedIn token exchange error: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Fetches user profile from LinkedIn API.
  """
  def get_profile(token) do
    headers = [{"Authorization", "Bearer #{token}"}]

    case Req.get("#{@linkedin_api_url}/me", headers: headers) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %Req.Response{status: status, body: body}} ->
        Logger.error("LinkedIn profile fetch failed: #{status} - #{body}")
        {:error, "Profile fetch failed"}

      {:error, reason} ->
        Logger.error("LinkedIn profile error: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Fetches user email from LinkedIn API.
  """
  def get_email(token) do
    headers = [{"Authorization", "Bearer #{token}"}]

    case Req.get("#{@linkedin_api_url}/emailAddress?q=members&projection=(elements*(handle~))", headers: headers) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        data = Jason.decode!(body)
        email = get_in(data, ["elements", Access.at(0), "handle~", "emailAddress"])
        {:ok, email}

      {:ok, %Req.Response{status: status, body: body}} ->
        Logger.error("LinkedIn email fetch failed: #{status} - #{body}")
        {:error, "Email fetch failed"}

      {:error, reason} ->
        Logger.error("LinkedIn email error: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp get_client_id do
    config = load_auth_config()
    get_in(config, ["linkedin", "client_id"]) || System.get_env("LINKEDIN_CLIENT_ID")
  end

  defp get_client_secret do
    config = load_auth_config()
    get_in(config, ["linkedin", "client_secret"]) || System.get_env("LINKEDIN_CLIENT_SECRET")
  end

  defp get_redirect_uri do
    "http://localhost:4000/auth/linkedin/callback"
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
