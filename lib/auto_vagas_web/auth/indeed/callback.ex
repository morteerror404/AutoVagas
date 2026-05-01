defmodule AutoVagasWeb.Auth.Indeed.Callback do
  @moduledoc """
  Indeed OAuth callback handler.
  Processes authorization code and stores user info.
  """

  require Logger

  @doc """
  Processes OAuth callback from Indeed.
  """
  def handle(code) do
    case AutoVagas.Auth.Indeed.exchange_code(code) do
      {:ok, token} ->
        case AutoVagas.Auth.Indeed.get_profile(token) do
          {:ok, profile} ->
            save_profile(profile)
            {:ok, profile}

          {:error, reason} ->
            Logger.error("Failed to fetch Indeed profile: #{inspect(reason)}")
            {:error, reason}
        end

      {:error, reason} ->
        Logger.error("Indeed token exchange failed: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp save_profile(profile) do
    config_path = "priv/filters/auth_config.json"
    config = load_config()
    updated = put_in(config, ["indeed", "profile"], profile)
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
