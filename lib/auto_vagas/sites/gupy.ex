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
    "#{@base_url}/jobs?searchTerm=#{URI.encode(search_term)}&country=#{URI.encode(location)}"
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
  def parse(body) when is_binary(body) do
    case Jason.decode(body) do
      {:ok, json} -> parse_jobs(json["jobs"] || [])
      _ -> []
    end
  end

  @doc """
  Busca vagas usando a API da Gupy.
  """
  def fetch_jobs(search_term, location, _time_posted, _work_type) do
    url = build_url(search_term, location)
    case Req.get(url, retry: :transient) do
      {:ok, %{status: 200, body: body}} ->
        {:ok, parse(body)}
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp parse_jobs(jobs) when is_list(jobs) do
    Enum.map(jobs, &parse_job/1)
  end

  defp parse_job(job) do
    %{
      title: job["name"] || "",
      company: job["companyName"] || "",
      location: job["country"] || job["city"] || "",
      url: job["portalUrl"] || "",
      external_id: to_string(job["id"]),
      source: "gupy"
    }
  end
end
