defmodule AutoVagas.Crawler.Engine do
  @moduledoc """
  Engine central para executar crawling.
  Coordena requisições HTTP e processamento de respostas.
  """

  require Logger

  @doc """
  Executa crawling usando um adaptador específico.
  """
  def run(adapter_module, search_term) do
    Logger.info("Iniciando crawling com: #{adapter_module}")

    config = adapter_module.config()
    url = adapter_module.build_url(search_term)

    case Req.get(url, headers: config[:headers] || [], retry: :transient) do
      {:ok, %{status: 200, body: html}} ->
        adapter_module.parse(html)

      {:error, reason} ->
        Logger.error("Falha na instrumentação: #{inspect(reason)}")
        :error
    end
  end

  @doc """
  Executa busca de vagas usando a nova abordagem (API/Guest API/Scraping).
  """
  def fetch_jobs(source, search_term, location \\ nil, time_posted \\ nil, work_type \\ nil) do
    adapter = AutoVagas.Crawler.Adapter.adapter_for(source)

    case adapter do
      AutoVagas.Sites.LinkedIn ->
        # Usa nova implementação com múltiplas opções
        case AutoVagas.Sites.LinkedIn.fetch_jobs(search_term, location, time_posted, work_type) do
          {:ok, jobs} -> {:ok, jobs}
          {:error, reason} ->
            Logger.error("Erro em fetch_jobs: #{inspect(reason)}")
            :error
        end

      nil ->
        {:error, :invalid_source}

      _ ->
        # Outros adaptadores continuam com lógica antiga
        run(adapter, search_term)
    end
  end
end
