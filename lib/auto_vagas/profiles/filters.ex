defmodule AutoVagas.Filters do
  @moduledoc """
  Módulo central para processamento de filtros.
  Aplica regras globais e específicas por fonte.
  Padroniza filtros entre diferentes sites.
  """

  @doc """
  Filtros padrão AutoVagas com mapeamento para códigos específicos.
  """
  def standard_filters do
    %{
      "sort_by" => %{
        "recent" => "recent",
        "relevant" => "relevant"
      },
      "time_posted" => %{
        "any" => "",
        "r2592000" => "r2592000",
        "r604800" => "r604800",
        "r86400" => "r86400"
      },
      "experience_level" => %{
        "" => "",
        "internship" => "internship",
        "assistant" => "assistant",
        "junior" => "junior",
        "mid_senior" => "mid_senior",
        "director" => "director",
        "executive" => "executive"
      },
      "work_type" => %{
        "" => "",
        "full_time" => "1",
        "part_time" => "2",
        "contract" => "3",
        "temporary" => "4",
        "volunteer" => "5",
        "internship" => "6",
        "other" => "7"
      },
      "remote_type" => %{
        "" => "",
        "on_site" => "1",
        "hybrid" => "3",
        "remote" => "2"
      }
    }
  end

  @doc """
  Converte filtros do padrão AutoVagas para formato específico do LinkedIn.
  """
  def to_linkedin_filters(filters) when is_map(filters) do
    %{}
    |> maybe_put("f_TPR", Map.get(filters, "time_posted"))
    |> maybe_put("f_E", experience_to_linkedin(Map.get(filters, "experience_level")))
    |> maybe_put("f_WT", Map.get(filters, "work_type"))
    |> maybe_put("f_JT", remote_to_linkedin(Map.get(filters, "remote_type")))
    |> maybe_put("f_LAPA", if(Map.get(filters, "linkedin_easy_apply"), do: "1", else: nil))
    |> maybe_put("f_VC", if(Map.get(filters, "verified_only"), do: "1", else: nil))
    |> maybe_put("f_LA", if(Map.get(filters, "less_than_10_applicants"), do: "1", else: nil))
    |> maybe_put("f_NETW", if(Map.get(filters, "in_network"), do: "1", else: nil))
    |> maybe_put("f_2SC", if(Map.get(filters, "second_chance"), do: "1", else: nil))
    |> maybe_put("f_C", commitment_to_linkedin(Map.get(filters, "commitments")))
    |> maybe_put("or_facet.SB", Map.get(filters, "sector"))
    |> maybe_put("or_facet.F", Map.get(filters, "job_function"))
    |> maybe_put("or_facet.T", Map.get(filters, "job_title"))
  end

  @doc """
  Converte filtros do padrão AutoVagas para formato específico do Indeed.
  """
  def to_indeed_filters(filters) when is_map(filters) do
    %{}
    |> maybe_put("fromage", time_posted_to_indeed(Map.get(filters, "time_posted")))
    |> maybe_put("explvl", experience_to_indeed(Map.get(filters, "experience_level")))
    |> maybe_put("jt", work_type_to_indeed(Map.get(filters, "work_type")))
    |> maybe_put("remote", remote_to_indeed(Map.get(filters, "remote_type")))
    |> maybe_put("sc", commitment_to_indeed(Map.get(filters, "commitments")))
    |> maybe_put("q", build_indeed_query(filters))
  end

  @doc """
  Converte filtros do padrão AutoVagas para formato específico do Gupy.
  """
  def to_gupy_filters(filters) when is_map(filters) do
    %{}
    |> maybe_put("experienceLevel", Map.get(filters, "experience_level"))
    |> maybe_put("contractType", work_type_to_gupy(Map.get(filters, "work_type")))
    |> maybe_put("remote", remote_to_gupy(Map.get(filters, "remote_type")))
    |> maybe_put("sector", Map.get(filters, "sector"))
    |> maybe_put("commitment", Map.get(filters, "commitments"))
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, _key, ""), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)

  defp experience_to_linkedin("internship"), do: "1"
  defp experience_to_linkedin("assistant"), do: "2"
  defp experience_to_linkedin("junior"), do: "3"
  defp experience_to_linkedin("mid_senior"), do: "4"
  defp experience_to_linkedin("director"), do: "5"
  defp experience_to_linkedin("executive"), do: "6"
  defp experience_to_linkedin(_), do: nil

  defp remote_to_linkedin("on_site"), do: "1"
  defp remote_to_linkedin("hybrid"), do: "3"
  defp remote_to_linkedin("remote"), do: "2"
  defp remote_to_linkedin(_), do: nil

  defp commitment_to_linkedin("dei"), do: "1"
  defp commitment_to_linkedin("work_life"), do: "2"
  defp commitment_to_linkedin("social_impact"), do: "3"
  defp commitment_to_linkedin("career_growth"), do: "4"
  defp commitment_to_linkedin("environmental"), do: "5"
  defp commitment_to_linkedin(_), do: nil

  defp time_posted_to_indeed("r2592000"), do: "30"
  defp time_posted_to_indeed("r604800"), do: "7"
  defp time_posted_to_indeed("r86400"), do: "1"
  defp time_posted_to_indeed(_), do: nil

  defp experience_to_indeed("internship"), do: "intern"
  defp experience_to_indeed("assistant"), do: "entry_level"
  defp experience_to_indeed("junior"), do: "mid_level"
  defp experience_to_indeed("mid_senior"), do: "senior_level"
  defp experience_to_indeed("director"), do: "director"
  defp experience_to_indeed("executive"), do: "executive"
  defp experience_to_indeed(_), do: nil

  defp work_type_to_indeed("full_time"), do: "fulltime"
  defp work_type_to_indeed("part_time"), do: "parttime"
  defp work_type_to_indeed("contract"), do: "contract"
  defp work_type_to_indeed("temporary"), do: "temporary"
  defp work_type_to_indeed("volunteer"), do: "volunteer"
  defp work_type_to_indeed("internship"), do: "internship"
  defp work_type_to_indeed(_), do: nil

  defp remote_to_indeed("on_site"), do: "0"
  defp remote_to_indeed("hybrid"), do: "2"
  defp remote_to_indeed("remote"), do: "1"
  defp remote_to_indeed(_), do: nil

  defp commitment_to_indeed("dei"), do: "diversity"
  defp commitment_to_indeed("work_life"), do: "work_life_balance"
  defp commitment_to_indeed("social_impact"), do: "social_impact"
  defp commitment_to_indeed("career_growth"), do: "career_growth"
  defp commitment_to_indeed("environmental"), do: "environmental"
  defp commitment_to_indeed(_), do: nil

  defp work_type_to_gupy("full_time"), do: "FULL_TIME"
  defp work_type_to_gupy("part_time"), do: "PART_TIME"
  defp work_type_to_gupy("contract"), do: "CONTRACT"
  defp work_type_to_gupy("temporary"), do: "TEMPORARY"
  defp work_type_to_gupy("volunteer"), do: "VOLUNTEER"
  defp work_type_to_gupy("internship"), do: "INTERNSHIP"
  defp work_type_to_gupy(_), do: nil

  defp remote_to_gupy("on_site"), do: "false"
  defp remote_to_gupy("hybrid"), do: "hybrid"
  defp remote_to_gupy("remote"), do: "true"
  defp remote_to_gupy(_), do: nil

  defp build_indeed_query(filters) do
    parts = []
    parts = if Map.get(filters, "linkedin_easy_apply"), do: ["easy apply" | parts], else: parts
    parts = if Map.get(filters, "verified_only"), do: ["verified" | parts], else: parts
    parts = if Map.get(filters, "less_than_10_applicants"), do: ["less than 10 applicants" | parts], else: parts
    Enum.join(parts, " ")
  end

  # Funções originais mantidas para compatibilidade

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
    # Implementação futura baseada no Python crawler
    jobs
  end

  @doc """
  Aplica filtro de máximo de aplicações.
  """
  def apply_global_max_applications(jobs, nil), do: jobs
  def apply_global_max_applications(jobs, _max_apps) do
    # Implementação futura
    jobs
  end

  @doc """
  Aplica filtro de apenas remoto.
  """
  def apply_global_remote_only(jobs, false), do: jobs
  def apply_global_remote_only(jobs, true) do
    Enum.filter(jobs, fn job ->
      Map.get(job, "location", "") =~ ~r/remote/i
    end)
  end

  defp get_global_filters(user_info) do
    Map.get(user_info, "filters", %{})
    |> Map.get("global", %{})
  end

  defp get_source_filters(user_info, source) do
    Map.get(user_info, "filters", %{})
    |> Map.get(source, %{})
  end
end
