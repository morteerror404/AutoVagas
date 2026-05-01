defmodule AutoVagasWeb.Auth.LinkedIn.Callback do
  @moduledoc """
  LinkedIn OAuth callback handler.
  Processes authorization code and stores user info.
  """

  require Logger

  @doc """
  Processes OAuth callback from LinkedIn.
  """
  def handle(code) do
    case AutoVagas.Auth.LinkedIn.exchange_code(code) do
      {:ok, token_data} ->
        access_token = token_data["access_token"]

        case AutoVagas.Auth.LinkedIn.get_userinfo(access_token) do
          {:ok, userinfo} ->
            save_userinfo(userinfo)
            {:ok, userinfo}

          {:error, reason} ->
            Logger.error("Failed to fetch userinfo: #{inspect(reason)}")
            {:error, reason}
        end

      {:error, reason} ->
        Logger.error("Token exchange failed: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp save_userinfo(userinfo) do
    config_path = "priv/filters/auth_config.json"
    config = load_config()
    updated = put_in(config, ["linkedin", "userinfo"], userinfo)
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
