defmodule AutoVagas.Automation do
  @moduledoc """
  Módulo para automação de inscrição em vagas.
  Utiliza Wallaby para automação web com Chrome (padrão) ou Firefox.
  """

  require Logger

  @doc """
  Inicia sessão para automação usando Wallaby.
  """
  def start_session(browser \\ :chrome) do
    case browser do
      :chrome ->
        case System.find_executable("google-chrome") || System.find_executable("chromium") do
          nil ->
            Logger.error("Chrome/Chromium não encontrado. Usando modo simulação.")
            {:ok, %{browser: :simulation}}
          path ->
            Logger.info("Browser encontrado: #{path}")
            {:ok, %{browser: :chrome, path: path}}
        end

      :firefox ->
        # Tenta Firefox Developer Edition primeiro, depois Firefox normal
        firefox_dev = System.find_executable("firefox-developer-edition")
        firefox_normal = System.find_executable("firefox")
        
        cond do
          firefox_dev ->
            Logger.info("Firefox Developer Edition encontrado: #{firefox_dev}")
            {:ok, %{browser: :firefox, path: firefox_dev}}
          firefox_normal ->
            Logger.info("Firefox encontrado: #{firefox_normal}")
            {:ok, %{browser: :firefox, path: firefox_normal}}
          true ->
            Logger.error("Firefox não encontrado. Usando modo simulação.")
            {:ok, %{browser: :simulation}}
        end

      _ ->
        {:error, :unsupported_browser}
    end
  end

  @doc """
  Realiza inscrição em uma vaga do LinkedIn usando automação.
  """
  def apply_to_job(session, job_url, _user_info) do
    Logger.info("Iniciando inscrição automática em: #{job_url}")

    case session.browser do
      :chrome ->
        Logger.info("Automação com Chrome seria executada para: #{job_url}")
        # TODO: Implementar com Wallaby + Chrome
        # session = Wallaby.start_session()
        # Wallaby.visit(session, job_url)
        # ...
        {:ok, :would_apply}

      :firefox ->
        Logger.info("Automação com Firefox seria executada para: #{job_url}")
        # TODO: Implementar com Wallaby + Firefox (requer GeckoDriver)
        {:ok, :would_apply}

      :simulation ->
        Logger.info("[SIMULAÇÃO] Inscrição realizada para: #{job_url}")
        {:ok, :simulated}

      _ ->
        {:error, :invalid_session}
    end
  end

  @doc """
  Fecha a sessão.
  """
  def end_session(_session) do
    Logger.info("Encerrando sessão de automação")
    {:ok, :closed}
  end
end
