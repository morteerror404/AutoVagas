defmodule AutoVagas.LinkedinProfile do
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
        # Modo hibrido: tenta API primeiro, depois scraping
        case extract_with_fallback(profile_url, opts) do
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

  defp extract_with_fallback(url, opts) do
    # Verifica se temos token valido para API
    token = get_access_token()

    cond do
      token != nil && Keyword.get(opts, :use_api, true) ->
        Logger.info("Tentando API do LinkedIn...")
        case extract_via_api_with_token(url, token) do
          {:ok, data} -> {:ok, data}
          {:error, _reason} ->
            Logger.warning("API falhou, tentando scraping...")
            extract_via_scraping(url, opts)
        end

      Keyword.get(opts, :use_scraping, true) ->
        Logger.info("Usando scraping do LinkedIn...")
        extract_via_scraping(url, opts)

      true ->
        Logger.info("Tentando API sem token...")
        extract_via_api(url, opts)
    end
  end

  defp get_access_token do
    config_path = "priv/filters/auth_config.json"
    if File.exists?(config_path) do
      config = File.read!(config_path) |> Jason.decode!()
      get_in(config, ["linkedin", "access_token"])
    else
      nil
    end
  end

  defp extract_via_api_with_token(_url, token) do
    case AutoVagas.Auth.LinkedIn.get_userinfo(token) do
      {:ok, userinfo} -> {:ok, parse_userinfo(userinfo)}
      error -> error
    end
  end

  defp extract_via_api(url, _opts) do
    token = get_access_token()
    if token do
      extract_via_api_with_token(url, token)
    else
      {:error, "No access token available"}
    end
  end

  defp extract_via_scraping(url, _opts) do
    case AutoVagas.Automation.Automation.scrape_linkedin_profile(url) do
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

  defp parse_userinfo(userinfo) do
    %{
      "name" => userinfo["name"] || "#{userinfo["given_name"]} #{userinfo["family_name"]}",
      "headline" => userinfo["headline"] || "",
      "location" => userinfo["locale"] || "",
      "email" => userinfo["email"] || "",
      "picture" => userinfo["picture"] || ""
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

  @doc """
  Retorna configuracoes para o adapter.
  """
  def config do
    %{
      headers: [{"User-Agent", "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36"}],
      use_rapidapi: get_env_bool("LINKEDIN_USE_RAPIDAPI", false),
      use_rockapis: get_env_bool("LINKEDIN_USE_ROCKAPIS", false),
      use_jsearch: get_env_bool("LINKEDIN_USE_JSEARCH", false)
    }
  end

  @doc """
  Constrói URL para busca (modo legado).
  """
  def build_url(search_term, location \\ nil, time_posted \\ nil, work_type \\ nil) do
    query = %{}
    query = if search_term != "", do: Map.put(query, "keywords", search_term), else: query
    query = if location, do: Map.put(query, "location", location), else: query
    query = if time_posted, do: Map.put(query, "f_TPR", time_posted), else: query
    query = if work_type, do: Map.put(query, "f_WT", work_type_to_code(work_type)), else: query

    "https://www.linkedin.com/jobs/search/##{URI.encode_query(query)}"
  end

  @doc """
  Busca vagas usando o metodo configurado (RapidAPI, Rockapis, JSearch, Guest).
  """
  def fetch_jobs(search_term, location \\ nil, time_posted \\ nil, work_type \\ nil) do
    cond do
      config()[:use_rapidapi] -> fetch_via_rapidapi(search_term, location, time_posted, work_type)
      config()[:use_rockapis] -> fetch_via_rockapis(search_term, location, time_posted, work_type)
      config()[:use_jsearch] -> fetch_via_jsearch(search_term, location, time_posted, work_type)
      true -> fetch_via_guest_api(search_term, location, time_posted, work_type)
    end
  end

  @doc """
  Busca via RapidAPI (LinkedIn Job Search API).
  """
  def fetch_via_rapidapi(search_term, location, time_posted, work_type) do
    api_key = System.get_env("RAPIDAPI_KEY")
    if api_key do
      url = "https://linkedin-job-search-api.p.rapidapi.com/active-jobs"
      headers = [
        {"X-RapidAPI-Key", api_key},
        {"X-RapidAPI-Host", "linkedin-job-search-api.p.rapidapi.com"}
      ]
      params = %{"keywords" => search_term, "location" => location || "Brazil"}
      do_get(url, headers, params)
    else
      Logger.warning("RAPIDAPI_KEY nao configurada, tentando proximo metodo")
      fetch_via_rockapis(search_term, location, time_posted, work_type)
    end
  end

  @doc """
  Busca via Rockapis.
  """
  def fetch_via_rockapis(search_term, location, time_posted, work_type) do
    api_key = System.get_env("ROCKAPIS_KEY")
    if api_key do
      url = "https://linkedin-data-api.p.rapidapi.com/jobs/search"
      headers = [
        {"X-RapidAPI-Key", api_key},
        {"X-RapidAPI-Host", "linkedin-data-api.p.rapidapi.com"}
      ]
      params = %{"query" => search_term, "location" => location || "Brazil"}
      do_get(url, headers, params)
    else
      Logger.warning("ROCKAPIS_KEY nao configurada, tentando proximo metodo")
      fetch_via_jsearch(search_term, location, time_posted, work_type)
    end
  end

  @doc """
  Busca via JSearch API.
  """
  def fetch_via_jsearch(search_term, location, time_posted, work_type) do
    api_key = System.get_env("JSEARCH_API_KEY")
    if api_key do
      url = "https://jsearch.p.rapidapi.com/search"
      headers = [
        {"X-RapidAPI-Key", api_key},
        {"X-RapidAPI-Host", "jsearch.p.rapidapi.com"}
      ]
      params = %{"query" => search_term, "location" => location || "Brazil", "site" => "linkedin"}
      do_get(url, headers, params)
    else
      Logger.warning("JSEARCH_API_KEY nao configurada, usando Guest API")
      fetch_via_guest_api(search_term, location, time_posted, work_type)
    end
  end

  @doc """
  Busca via Guest API (fallback, sem autenticacao).
  """
  def fetch_via_guest_api(search_term, location, time_posted, work_type) do
    url = build_url(search_term, location, time_posted, work_type)
    headers = config()[:headers]

    case Req.get(url, headers: headers, retry: :transient) do
      {:ok, %Req.Response{status: 200, body: html}} ->
        parse(html)
      {:ok, %Req.Response{status: status}} ->
        Logger.error("Guest API falhou: #{status}")
        :error
      {:error, reason} ->
        Logger.error("Erro na Guest API: #{inspect(reason)}")
        :error
    end
  end

  @doc """
  Parseia HTML do LinkedIn para extrair vagas.
  """
  def parse(html) do
    with {:ok, document} <- Floki.parse_document(html) do
      document
      |> Floki.find(".job-result-card")
      |> Enum.map(&parse_job_card/1)
      |> Enum.filter(&(&1 != nil))
    else
      _ -> []
    end
  end

  # Internos

  defp do_get(url, headers, params) do
    case Req.get(url, headers: headers, params: params, retry: :transient) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        jobs = parse_api_response(body)
        {:ok, jobs}
      {:ok, %Req.Response{status: status, body: body}} ->
        Logger.error("API falhou: #{status} - #{inspect(body)}")
        {:error, "API error: #{status}"}
      {:error, reason} ->
        Logger.error("Erro de conexao: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp parse_api_response(body) when is_binary(body) do
    case Jason.decode(body) do
      {:ok, data} -> extract_jobs_from_api(data)
      {:error, _} -> []
    end
  end
  defp parse_api_response(data), do: extract_jobs_from_api(data)

  defp extract_jobs_from_api(data) do
    # Tenta diferentes formatos de resposta da API
    cond do
      Map.get(data, "jobs") -> Map.get(data, "jobs", [])
      Map.get(data, "results") -> Map.get(data, "results", [])
      Map.get(data, "data") -> Map.get(data, "data", [])
      true -> []
    end
  end

  defp parse_job_card(card) do
    title = Floki.find(card, ".job-result-card__title") |> Floki.text() |> String.trim()
    company = Floki.find(card, ".job-result-card__subtitle") |> Floki.text() |> String.trim()
    location = Floki.find(card, ".job-result-card__location") |> Floki.text() |> String.trim()

    if title != "" do
      %{
        "title" => title,
        "company" => company,
        "location" => location,
        "source" => "linkedin"
      }
    else
      nil
    end
  end

  defp work_type_to_code("remote"), do: "2"
  defp work_type_to_code("on_site"), do: "1"
  defp work_type_to_code("hybrid"), do: "3"
  defp work_type_to_code(_), do: ""

  defp get_env_bool(key, default) do
    case System.get_env(key) do
      "true" -> true
      "1" -> true
      _ -> default
    end
  end

end
