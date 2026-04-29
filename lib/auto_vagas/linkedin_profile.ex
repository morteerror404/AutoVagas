defmodule AutoVagas.LinkedInProfile do
  @moduledoc """
  Extrai informações do perfil LinkedIn do usuário.
  Suporta URL do perfil e atualização via scraping ou API.
  """

  require Logger
  alias AutoVagas.UserInfo, as: UserConfig

  @doc """
  Busca perfil LinkedIn e extrai dados estruturados.
  Se a URL estiver salva em user_info, usa ela.
  """
  def fetch_and_update(user_info \\ %{}, opts \\ []) do
    profile_url = get_profile_url(user_info)

    if profile_url do
      case extract_from_url(profile_url, opts) do
        {:ok, profile_data} ->
          merged = merge_profile_data(user_info, profile_data)
          UserConfig.save(merged)
          {:ok, merged}

        error ->
          Logger.error("Falha ao buscar perfil LinkedIn: #{inspect(error)}")
          error
      end
    else
      {:error, "URL do perfil LinkedIn não configurada"}
    end
  end

  @doc """
  Define URL do perfil LinkedIn e salva em user_info.
  """
  def set_profile_url(user_info, url) do
    updated = put_in(user_info, ["linkedin_profile_url"], url)
    UserConfig.save(updated)
    updated
  end

  @doc """
  Extrai dados de uma URL do LinkedIn usando scraping (Wallaby) ou API.
  """
  def extract_from_url(url, opts \\ []) do
    use_api = Keyword.get(opts, :use_api, false)
    use_scraping = Keyword.get(opts, :use_scraping, true)

    cond do
      use_api -> extract_via_api(url, opts)
      use_scraping -> extract_via_scraping(url, opts)
      true -> extract_via_scraping(url, opts)
    end
  end

  defp extract_via_api(_url, _opts) do
    # Requer token OAuth válido
    case AutoVagas.Auth.LinkedIn.get_profile(nil) do
      {:ok, profile} -> parse_api_profile(profile)
      error -> error
    end
  end

  defp extract_via_scraping(url, _opts) do
    # Usa automation.ex ou Wallaby para scraping
    # Como LinkedIn requer JS, usamos Wallaby com Firefox
    case AutoVagas.Automation.scrape_linkedin_profile(url) do
      {:ok, html} -> parse_profile_html(html)
      error -> error
    end
  end

  defp parse_profile_html(html) do
    {:ok, document} = Floki.parse_document(html)

    %{}
    |> then(fn acc -> Map.merge(acc, extract_name(document)) end)
    |> then(fn acc -> Map.merge(acc, extract_headline(document)) end)
    |> then(fn acc -> Map.merge(acc, extract_location(document)) end)
    |> then(fn acc -> Map.merge(acc, extract_experience(document)) end)
    |> then(fn acc -> Map.merge(acc, extract_skills(document)) end)
    |> then(fn acc -> Map.merge(acc, extract_education(document)) end)
    |> wrap_result()
  end

  defp extract_name(doc) do
    name = doc
            |> Floki.find("h1")
            |> Floki.text()
            |> List.first()
            |> (fn nil -> ""; text -> String.trim(text) end).()

    Map.put(%{}, "name", name)
  end

  defp extract_headline(doc) do
    headline = doc
                |> Floki.find(".text-body-medium")
                |> Floki.text()
                |> List.first()
                |> (fn nil -> ""; text -> String.trim(text) end).()

    Map.put(%{}, "headline", headline)
  end

  defp extract_location(doc) do
    location = doc
                |> Floki.find(".text-body-small:contains(',')")
                |> Floki.text()
                |> List.first()
                |> (fn nil -> ""; text -> String.trim(text) end).()

    Map.put(%{}, "location", location)
  end

  defp extract_experience(doc) do
    experience = doc
                  |> Floki.find(".experience-item")
                  |> Enum.map(&parse_experience_item/1)
                  |> Enum.filter(&(&1 != nil))

    Map.put(%{}, "experience_raw", experience)
  end

  defp parse_experience_item(item) do
    title = Floki.find(item, ".t-bold") |> Floki.text() |> List.first()
    company = Floki.find(item, ".t-14") |> Floki.text() |> List.first()
    dates = Floki.find(item, ".t-14.t-normal") |> Floki.text() |> List.first()

    if title && company do
      %{
        "title" => String.trim(title),
        "company" => String.trim(company),
        "dates" => String.trim(dates || "")
      }
    else
      nil
    end
  end

  defp extract_skills(doc) do
    skills = doc
             |> Floki.find(".pv-skill-category-entity__name-text")
             |> Floki.text()
             |> Enum.map(&String.trim/1)
             |> Enum.filter(&(&1 != ""))

    Map.put(%{}, "skills", skills)
  end

  defp extract_education(doc) do
    education = doc
                 |> Floki.find(".education-item")
                 |> Enum.map(&parse_education_item/1)
                 |> Enum.filter(&(&1 != nil))

    Map.put(%{}, "education", education)
  end

  defp parse_education_item(item) do
    school = Floki.find(item, ".t-bold") |> Floki.text() |> List.first()
    degree = Floki.find(item, ".t-14") |> Floki.text() |> List.first()

    if school do
      %{
        "school" => String.trim(school),
        "degree" => String.trim(degree || "")
      }
    else
      nil
    end
  end

  defp parse_api_profile(profile) do
    %{
      "name" => profile["localizedFirstName"] <> " " <> profile["localizedLastName"],
      "headline" => profile["headline"] || "",
      "location" => get_in(profile, ["location", "name"]) || ""
    }
  end

  defp merge_profile_data(user_info, profile_data) do
    user_info
    |> Map.update("name", get(profile_data, "name"), fn _ -> get(profile_data, "name") end)
    |> Map.update("location", get(profile_data, "location"), fn v -> 
      if get(profile_data, "location") != "", do: get(profile_data, "location"), else: v
    end)
    |> Map.put("linkedin_profile", profile_data)
  end

  defp get(map, key) do
    Map.get(map, key, "")
  end

  defp wrap_result(data) do
    {:ok, data}
  end

  defp get_profile_url(user_info) do
    Map.get(user_info, "linkedin_profile_url") || 
    get_in(user_info, ["linkedin_profile", "url"])
  end
end
