defmodule AutoVagas.UserProfile do
  @moduledoc """
  Gerencia perfil do usuário (nome, LinkedIn, preferências de busca).
  Separa as configurações de perfil das integrações técnicas.
  """

  alias AutoVagas.UserInfo, as: UserConfig
  alias AutoVagas.LinkedInProfile

  @doc """
  Atualiza perfil com dados do LinkedIn.
  """
  def sync_linkedin_profile(user_info) do
    case LinkedInProfile.fetch_and_update(user_info, use_scraping: true) do
      {:ok, updated} ->
        # Extrai skills e experiências para o formato do AutoVagas
        merged = merge_linkedin_data(user_info, updated)
        UserConfig.save(merged)
        {:ok, merged}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Atualiza informações básicas do usuário.
  """
  def update_basic_info(user_info, attrs) do
    updated =
      user_info
      |> Map.update("name", Map.get(attrs, "name", ""), & &1)
      |> Map.update("location", Map.get(attrs, "location", ""), & &1)
      |> Map.update("linkedin_profile_url", Map.get(attrs, "linkedin_url", ""), & &1)

    UserConfig.save(updated)
    updated
  end

  @doc """
  Atualiza preferências de busca baseadas no crawler Python.
  """
  def update_search_preferences(user_info, prefs) do
    filters = Map.get(user_info, "filters", %{})
    global = Map.get(filters, "global", %{})

    updated_global =
      global
      |> Map.put("experience_levels", Map.get(prefs, "experience_levels", []))
      |> Map.put("job_types", Map.get(prefs, "job_types", []))
      |> Map.put("date_range", Map.get(prefs, "date_range", "all"))
      |> Map.put("company_blacklist", Map.get(prefs, "company_blacklist", []))
      |> Map.put("title_blacklist", Map.get(prefs, "title_blacklist", []))

    updated_filters = Map.put(filters, "global", updated_global)
    updated = Map.put(user_info, "filters", updated_filters)

    UserConfig.save(updated)
    updated
  end

  defp merge_linkedin_data(user_info, linkedin_data) do
    user_info
    |> Map.put("name", Map.get(linkedin_data, "name", Map.get(user_info, "name", "")))
    |> Map.put("location", Map.get(linkedin_data, "location", Map.get(user_info, "location", "")))
    |> Map.put("linkedin_profile", linkedin_data)
    |> merge_skills_from_linkedin(linkedin_data)
  end

  defp merge_skills_from_linkedin(user_info, data) do
    skills = Map.get(data, "skills", [])
    existing = Map.get(user_info, "skills", %{})
    technical = Map.get(existing, "technical", [])

    new_technical =
      skills
      |> Enum.map(fn skill ->
        %{"name" => skill, "level" => "Intermediate", "years" => 0}
      end)
      |> Enum.reject(fn s -> Enum.any?(technical, &(&1["name"] == s["name"])) end)

    updated_technical = technical ++ new_technical
    updated_skills = Map.put(existing, "technical", updated_technical)
    Map.put(user_info, "skills", updated_skills)
  end
end
