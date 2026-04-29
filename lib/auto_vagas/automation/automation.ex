defmodule AutoVagas.Automation do
  @moduledoc """
  Módulo para automação de inscrição em vagas.
  Utiliza Wallaby para automação web com Chrome (padrão) ou Firefox.
  """

  require Logger

  @doc """
  Inicia sessão para automação usando Wallaby.
  """
  def start_session(_browser \\ :firefox) do
    # Apenas Firefox Developer Edition é suportado para automação
    firefox_dev = System.find_executable("firefox-developer-edition")
    
    case firefox_dev do
      nil ->
        Logger.error("Firefox Developer Edition não encontrado em: /usr/bin/firefox-developer-edition")
        Logger.info("Instale com: snap install firefox --beta (ou via apt)")
        {:error, :firefox_dev_not_found}
      
      path ->
        Logger.info("Firefox Developer Edition encontrado: #{path}")
        {:ok, %{browser: :firefox, path: path}}
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
