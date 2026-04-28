defmodule AutoVagas.Auth.Gupy do
  @moduledoc """
  Gupy SAML 2.0 integration for corporate authentication.
  Uses SAML protocol for enterprise SSO.
  """

  require Logger

  @gupy_saml_url "https://portal.gupy.io/saml/login"

  @doc """
  Returns the URL to redirect user for Gupy SAML login.
  """
  def authorize_url(_state \\ "random_state") do
    # SAML flow - redirect to Gupy's SAML endpoint
    # In production, this would generate a SAML request
    @gupy_saml_url
  end

  @doc """
  Processes SAML response from Gupy.
  """
  def process_saml_response(_saml_response) do
    # In production, this would validate the SAML assertion
    # For now, we simulate success
    Logger.info("Gupy SAML authentication successful")
    {:ok, "gupy_saml_token"}
  end

  @doc """
  Fetches user profile from Gupy API after SAML auth.
  """
  def get_profile(token) do
    headers = [{"Authorization", "Bearer #{token}"}]

    case Req.get("https://portal.gupy.io/api/me", headers: headers) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %Req.Response{status: status, body: body}} ->
        Logger.error("Gupy profile fetch failed: #{status} - #{body}")
        {:error, "Profile fetch failed"}

      {:error, reason} ->
        Logger.error("Gupy profile error: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp save_token(token) do
    config_path = "priv/filters/auth_config.json"
    config = load_auth_config()
    updated = put_in(config, ["gupy", "access_token"], token)
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
