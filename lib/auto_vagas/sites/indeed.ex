defmodule AutoVagas.Crawler.Sites.Indeed do
  @moduledoc """
  Adapter específico para a plataforma de vagas do Indeed.
  """

  @behaviour AutoVagas.Crawler.Adapter

  @base_url "https://br.indeed.com/jobs"

  @doc """
  Configuração do Indeed.
  """
  @impl true
  def config do
    %{
      name: "Indeed",
      base_url: @base_url,
      requires_auth: false,
      rate_limit: 10
    }
  end

  @doc """
  Constrói URL de busca para o Indeed.
  """
  @impl true
  def build_url(
        search_term,
        location \\ "Brazil",
        _time_posted \\ "r86400",
        _work_type \\ "1%2C2%2C3",
        _user_config \\ %{}
      ) do
    query_params =
      [
        {"q", search_term},
        {"l", location}
      ]
      |> Enum.map(fn {k, v} -> "#{k}=#{URI.encode(v)}" end)
      |> Enum.join("&")

    "#{@base_url}?#{query_params}"
  end

  @doc """
  Constrói URLs de busca para uma lista de palavras-chaves.
  """
  @impl true
  @spec build_urls([String.t()], keyword(), map()) :: [{String.t(), String.t()}]
  def build_urls(keywords, opts \\ [], _user_config \\ %{}) when is_list(keywords) do
    location = Keyword.get(opts, :location, "Brazil")

    Enum.map(keywords, fn keyword ->
      url = build_url(keyword, location)
      {keyword, url}
    end)
  end

  @doc """
  Parsing dos resultados de vagas na página HTML do Indeed.
  """
  @impl true
  def parse(html) do
    {:ok, document} = Floki.parse_document(html)

    document
    |> Floki.find(".job-card-container")
    |> Enum.map(&parse_job_card/1)
    |> Enum.reject(&is_nil/1)
  end

  @doc """
  Busca vagas usando a lógica padrão (HTML scraping).
  """
  def fetch_jobs(search_term, location, _time_posted, _work_type) do
    url = build_url(search_term, location)
    case Req.get(url, retry: :transient) do
      {:ok, %{status: 200, body: html}} ->
        {:ok, parse(html)}
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp parse_job_card(card) do
    with title_elem <- Floki.find(card, ".job-title"),
         title when title != [] <- Floki.text(title_elem),
         company_elem <- Floki.find(card, ".company-name"),
         company when company != [] <- Floki.text(company_elem),
         location_elem <- Floki.find(card, ".company-location"),
         location <- Floki.text(location_elem),
         link_elem <- Floki.find(card, ".job-card-container a"),
         [href] <- Floki.attribute(link_elem, "href"),
         [job_id] <- Floki.attribute(card, "data-jk") do
      %{
        title: String.trim(title),
        company: String.trim(company),
        location: String.trim(location),
        url: "https://br.indeed.com" <> href,
        external_id: job_id,
        source: "indeed"
      }
    else
      _ -> nil
    end
  end
end
