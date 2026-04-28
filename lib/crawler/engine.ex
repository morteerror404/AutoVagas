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
end
