defmodule AutoVagas.LinkedInProfile do
  @moduledoc """
  Extrai informações do perfil LinkedIn do usuário.
  Suporta URL do perfil e atualização via scraping ou API.
  """

  require Logger
  alias AutoVagas.UserInfo, as: UserConfig

  @doc """
  Busca perfil LinkedIn e extrai dados estruturados.
  """
  def fetch_and_update(user_info \\ %{}, opts \\ []) do
    case get_profile_url(user_info) do
      nil ->
        {:error, "URL do perfil LinkedIn não configurada"}

      profile_url ->
        case extract_from_url(profile_url, opts) do
          {:ok, profile_data} ->
            merged = merge_profile_data(user_info, profile_data)
            UserConfig.save(merged)
            {:ok, merged}

          {:error, reason} ->
            Logger.error("Falha ao buscar perfil LinkedIn: #{inspect(reason)}")
            {:error, reason}
        end
    end
  end

  def set_profile_url(user_info, url) do
    updated = put_in(user_info, ["linkedin_profile_url"], url)
    UserConfig.save(updated)
    updated
  end

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
    case AutoVagas.Auth.LinkedIn.get_profile(nil) do
      {:ok, profile} -> {:ok, parse_api_profile(profile)}
      error -> error
    end
  end

  defp extract_via_scraping(url, _opts) do
    case AutoVagas.Automation.scrape_linkedin_profile(url) do
      {:ok, html} -> parse_profile_html(html)
      error -> error
    end
  end

  defp parse_profile_html(html) do
    {:ok, document} = Floki.parse_document(html)

    %{}
    |> Map.merge(extract_name(document))
    |> Map.merge(extract_headline(document))
    |> Map.merge(extract_location(document))
    |> Map.merge(extract_experience(document))
    |> Map.merge(extract_skills(document))
    |> Map.merge(extract_education(document))
  end

  defp extract_name(doc) do
    name =
      doc
      |> Floki.find("h1")
      |> Floki.text()
      |> List.first()
      |> String.trim()

    %{"name" => name || ""}
  end

  defp extract_headline(doc) do
    headline =
      doc
      |> Floki.find(".text-body-medium")
      |> Floki.text()
      |> List.first()
      |> String.trim()

    %{"headline" => headline || ""}
  end

  defp extract_location(doc) do
    location =
      doc
      |> Floki.find(".text-body-small:contains(',')")
      |> Floki.text()
      |> List.first()
      |> String.trim()

    %{"location" => location || ""}
  end

  defp extract_experience(doc) do
    experience =
      doc
      |> Floki.find(".experience-item")
      |> Enum.map(&parse_experience_item/1)
      |> Enum.filter(&(&1 != nil))

    %{"experience_raw" => experience}
  end

  defp parse_experience_item(item) do
    title = Floki.find(item, ".t-bold") |> Floki.text() |> List.first()
    company = Floki.find(item, ".t-14") |> Floki.text() |> List.first()

    if title && company do
      %{
        "title" => String.trim(title),
        "company" => String.trim(company)
      }
    else
      nil
    end
  end

  defp extract_skills(doc) do
    skills =
      doc
      |> Floki.find(".pv-skill-category-entity__name-text")
      |> Floki.text()
      |> Enum.map(&String.trim/1)
      |> Enum.filter(&(&1 != ""))

    %{"skills" => skills}
  end

  defp extract_education(doc) do
    education =
      doc
      |> Floki.find(".education-item")
      |> Enum.map(&parse_education_item/1)
      |> Enum.filter(&(&1 != nil))

    %{"education" => education}
  end

  defp parse_education_item(item) do
    school = Floki.find(item, ".t-bold") |> Floki.text() |> List.first()

    if school do
      %{"school" => String.trim(school)}
    else
      nil
    end
  end

  defp parse_api_profile(profile) do
    %{
      "name" => "#{profile["localizedFirstName"]} #{profile["localizedLastName"]}",
      "headline" => profile["headline"] || "",
      "location" => get_in(profile, ["location", "name"]) || ""
    }
  end

  defp merge_profile_data(user_info, profile_data) do
    user_info
    |> Map.update("name", profile_data["name"] || "", fn _ -> profile_data["name"] || "" end)
    |> Map.update("location", profile_data["location"] || "", fn v ->
      if profile_data["location"] && profile_data["location"] != "", do: profile_data["location"], else: v
    end)
    |> Map.put("linkedin_profile", profile_data)
  end

  defp get_profile_url(user_info) do
    Map.get(user_info, "linkedin_profile_url") ||
      get_in(user_info, ["linkedin_profile", "url"])
  end
end
