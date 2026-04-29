defmodule AutoVagas.Crawler.Sites.LinkedIn do
  @moduledoc """
  Adapter específico para a plataforma de vagas do LinkedIn.
  """

  @behaviour AutoVagas.Crawler.Adapter

  alias AutoVagas.Crawler.UserConfig

  @base_url "https://www.linkedin.com/jobs/search/"

  @doc """
  Configuração do LinkedIn.
  """
  @impl true
  def config do
    %{
      name: "LinkedIn",
      base_url: @base_url,
      requires_auth: false,
      rate_limit: 10
    }
  end

  @doc """
  Constrói URL de busca para o LinkedIn usando configurações do usuário.
  """
  @impl true
  def build_url(
        search_term,
        location \\ nil,
        time_posted \\ nil,
        work_type \\ nil,
        user_config \\ %{}
      ) do
    search_term = to_string(search_term)
    user_loc = location || UserConfig.default_location()
    user_time = time_posted || get_in(UserConfig.default_filters(), ["time_posted"]) || "r86400"

    user_work =
      work_type || get_in(UserConfig.default_filters(), ["work_type"]) ||
        Map.get(work_type_to_param(user_config), "linkedin", "1%2C2%2C3")

    query_params =
      [
        {"keywords", URI.encode(search_term)},
        {"location", user_loc},
        {"f_TPR", user_time},
        {"f_WT", user_work},
        {"sortBy", "DD"}
      ]
      |> Enum.map(fn {k, v} -> "#{k}=#{v}" end)
      |> Enum.join("&")

    "#{@base_url}?#{query_params}"
  end

  @doc """
  Constrói URLs de busca para uma lista de palavras-chaves.
  """
  @impl true
  @spec build_urls([String.t()], keyword(), map()) :: [{String.t(), String.t()}]
  def build_urls(keywords, opts \\ [], user_config \\ %{}) when is_list(keywords) do
    location = Keyword.get(opts, :location) || UserConfig.default_location()

    time_posted =
      Keyword.get(opts, :time_posted) || get_in(UserConfig.default_filters(), ["time_posted"]) ||
        "r86400"

    work_type =
      Keyword.get(opts, :work_type) ||
        Map.get(work_type_to_param(user_config), "linkedin", "1%2C2%2C3")

    source_config = UserConfig.source_config("linkedin")
    filters = Map.get(source_config, "include_words", [])

    Enum.map(keywords, fn keyword ->
      filtered =
        if filters != [] do
          keyword <> " " <> Enum.join(filters, " ")
        else
          keyword
        end

      url = build_url(filtered, location, time_posted, work_type, user_config)
      {keyword, url}
    end)
  end

  @doc """
  Parsing dos resultados de vaga na página HTML do LinkedIn.
  """
  @impl true
  def parse(html) do
    {:ok, document} = Floki.parse_document(html)

    document
    |> Floki.find(".job-card-container")
    |> Enum.map(&parse_job_card/1)
    |> Enum.reject(&is_nil/1)
  end

  defp parse_job_card(card) do
    with title_elem <- Floki.find(card, ".job-card-list__title"),
         title when title != [] <- Floki.text(title_elem),
         company_elem <- Floki.find(card, ".job-card-container__company-name"),
         company <- Floki.text(company_elem),
         location_elem <- Floki.find(card, ".job-card-container__metadata-item"),
         location <- Floki.text(location_elem),
         link_elem <- Floki.find(card, ".job-card-list__title a"),
         href when href != [] <- Floki.attribute(link_elem, "href"),
         [job_id] <- Floki.attribute(card, "data-job-id") do
      %{
        title: String.trim(title),
        company: String.trim(company),
        location: String.trim(location),
        url: "https://www.linkedin.com" <> List.first(href),
        external_id: job_id,
        source: "linkedin"
      }
    else
      _ -> nil
    end
  end

  defp work_type_to_param(user_config) do
    work = Map.get(user_config, "work_configs", %{})

    %{
      "linkedin" =>
        case Map.get(work, "remote", %{}) |> Map.get("max_distance_km") do
          nil -> "2"
          _ -> "1%2C2%2C3"
        end
    }
  end
end
