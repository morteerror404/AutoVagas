defmodule AutoVagas.Filters do
  @moduledoc """
  Módulo central para processamento de filtros.
  Aplica regras globais e específicas por fonte.
  """

  @doc """
  Aplica todos os filtros em uma lista de vagas.
  """
  def apply_all(jobs, source, user_info) do
    global_filters = get_global_filters(user_info)
    source_filters = get_source_filters(user_info, source)

    jobs
    |> apply_include_words(source_filters["include_words"] || [])
    |> apply_exclude_words(source_filters["exclude_words"] || [])
    |> apply_global_min_experience(global_filters["min_experience_years"])
    |> apply_global_max_applications(global_filters["max_applications"])
    |> apply_global_remote_only(global_filters["remote_only"] || false)
  end

  @doc """
  Aplica filtro de palavras para incluir.
  """
  def apply_include_words(jobs, []), do: jobs
  def apply_include_words(jobs, include_words) do
    Enum.filter(jobs, fn job ->
      title = Map.get(job, "title", "")
      Enum.any?(include_words, &String.contains?(title, &1))
    end)
  end

  @doc """
  Aplica filtro de palavras para excluir.
  """
  def apply_exclude_words(jobs, []), do: jobs
  def apply_exclude_words(jobs, exclude_words) do
    Enum.reject(jobs, fn job ->
      title = Map.get(job, "title", "")
      Enum.any?(exclude_words, &String.contains?(title, &1))
    end)
  end

  @doc """
  Aplica filtro de experiência mínima.
  """
  def apply_global_min_experience(jobs, nil), do: jobs
  def apply_global_min_experience(jobs, _min_years) do
    # Aqui seria necessário ter dados de experiência no job
    # Por enquanto, retorna os jobs sem filtrar
    jobs
  end

  @doc """
  Aplica filtro de máximo de aplicações.
  """
  def apply_global_max_applications(jobs, nil), do: jobs
  def apply_global_max_applications(jobs, _max_apps) do
    # Aqui seria necessário contar aplicações
    # Por enquanto, retorna os jobs sem filtrar
    jobs
  end

  @doc """
  Aplica filtro de apenas remotos.
  """
  def apply_global_remote_only(jobs, false), do: jobs
  def apply_global_remote_only(jobs, true) do
    Enum.filter(jobs, fn job ->
      location = Map.get(job, "location", "")
      String.contains?(location, "remote")
    end)
  end

  defp get_global_filters(user_info) do
    filters = Map.get(user_info, "filters", %{})
    Map.get(filters, "global", %{})
  end

  defp get_source_filters(user_info, source) do
    filters = Map.get(user_info, "filters", %{})
    by_source = Map.get(filters, "by_source", %{})
    Map.get(by_source, source, %{})
  end
end
