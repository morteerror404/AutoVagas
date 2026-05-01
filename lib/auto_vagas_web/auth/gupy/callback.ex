defmodule AutoVagasWeb.Auth.Gupy.Callback do
  @moduledoc """
  Gupy SAML callback handler.
  Processes SAML response and stores user info.
  """

  require Logger

  @doc """
  Processes SAML callback from Gupy.
  """
  def handle(saml_response) do
    case AutoVagas.Auth.Gupy.process_saml_response(saml_response) do
      {:ok, token} ->
        case AutoVagas.Auth.Gupy.get_profile(token) do
          {:ok, profile} ->
            save_profile(profile)
            {:ok, profile}

          error ->
            Logger.error("Failed to fetch Gupy profile: #{inspect(error)}")
            error
        end

      error ->
        Logger.error("Gupy SAML processing failed: #{inspect(error)}")
        error
    end
  end

  defp save_profile(profile) do
    config_path = "priv/filters/auth_config.json"
    config = load_config()
    updated = put_in(config, ["gupy", "profile"], profile)
    File.write!(config_path, Jason.encode!(updated, pretty: true))
  end

  defp load_config do
    path = "priv/filters/auth_config.json"
    if File.exists?(path) do
      path |> File.read!() |> Jason.decode!()
    else
      %{}
    end
  end
end
