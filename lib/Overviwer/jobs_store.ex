defmodule AutoVagas.Overviwer.JobsStore do
  @moduledoc """
  Interface simples para carregar vagas do Mnesia.
  Delega operações complexas ao SearchManager.
  """

  alias AutoVagas.Mnesia.SearchManager

  @doc """
  Carrega todas as vagas de todas as buscas.
  """
  def load do
    SearchManager.list_searches()
    |> Enum.flat_map(fn {_id, search} ->
      SearchManager.list_jobs(search.id)
    end)
    |> Enum.map(fn {_id, job} -> job end)
  end

  @doc """
  Salva lista de vagas (adiciona a busca especificada ou cria busca padrao).
  """
  def save(jobs) when is_list(jobs) do
    {:ok, search_id} = SearchManager.create_search("manual", ["linkedin", "indeed", "gupy"])

    Enum.each(jobs, fn job ->
      SearchManager.add_job(search_id, job)
    end)

    :ok
  end

  def save(_), do: :ok

  @doc """
  Limpa todas as vagas (remove todas as buscas).
  """
  def clear do
    SearchManager.list_searches()
    |> Enum.each(fn {id, _search} ->
      SearchManager.delete_search(id)
    end)

    :ok
  end
end
