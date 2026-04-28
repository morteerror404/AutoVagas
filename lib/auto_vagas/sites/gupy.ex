defmodule AutoVagas.Crawler.Sites.Gupy do
  @moduledoc """
  Adapter específico para a plataforma de vagas da Gupy.
  """

  @behaviour AutoVagas.Crawler.Adapter

  @base_url "https://portal.gupy.io/api"

  @doc """
  Configuração da Gupy.
  """
  @impl true
  def config do
    %{
      name: "Gupy",
      base_url: @base_url,
      requires_auth: false,
      rate_limit: 10
    }
  end

  @doc """
  Constrói URL de busca para a Gupy (API).
  """
  @impl true
  def build_url(search_term, location \\ "Brazil", _time_posted \\ "r86400", _work_type \\ "all", _user_config \\ %{}) do
    "#{@base_url}/jobs?searchTerm=#{URI.encode(search_term)}&county=#{URI.encode(location)}"
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
  Parsing dos resultados de vagas da API da Gupy (JSON).
  """
  @impl true
  def parse(html) when is_binary(html) do
    case Jason.decode(html) do
      {:ok, %{"jobs" => jobs}} ->
        parse_jobs(jobs)

      _ ->
        []
    end
  end

  def parse(json) when is_map(json) do
    parse_jobs(json["jobs"] || [])
  end

  defp parse_jobs(jobs) do
    Enum.map(jobs, &parse_job/1)
  end

  defp parse_job(job) do
    %{
      title: job["name"] || "",
      company: job["companyName"] || "",
      location: job["county"] || job["city"] || "",
      url: job["portalUrl"] || "",
      external_id: to_string(job["id"]),
      source: "gupy"
    }
  end
end
