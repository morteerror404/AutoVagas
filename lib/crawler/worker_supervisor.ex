defmodule AutoVagas.Crawler.WorkerSupervisor do
  @moduledoc """
  Supervisor Dinâmico para gerenciar múltiplos workers de crawling.
  Cada search_id tem seu próprio worker.
  """

  use DynamicSupervisor
  require Logger

  def start_link(_opts \\ []) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  Inicia um worker para uma busca específica.
  """
  def start_search(search_config) do
    spec = {AutoVagas.Crawler.Worker, search_config}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @doc """
  Para um worker específico.
  """
  def stop_search(search_id) do
    name = :"crawler_worker_#{search_id}"
    DynamicSupervisor.terminate_child(__MODULE__, {AutoVagas.Crawler.Worker, name})
  end

  @doc """
  Lista todos os workers ativos.
  """
  def list_workers do
    DynamicSupervisor.which_children(__MODULE__)
  end

  @doc """
  Retorna a contagem de workers ativos.
  """
  def count_workers do
    length(list_workers())
  end
end