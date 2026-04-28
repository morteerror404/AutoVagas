defmodule AutoVagas.Crawler.Filter do
  @moduledoc """
  Módulo de filtros e regras de exclusão para vagas capturadas.
  """

  @filters_dir "priv/filters"

  @doc """
  Lista todos os filtros salvos.
  """
  @spec list_filters() :: [map()]
  def list_filters do
    if File.exists?(@filters_dir) do
      @filters_dir
      |> File.ls!()
      |> Enum.filter(&String.ends_with?(&1, ".json"))
      |> Enum.map(fn file ->
        path = Path.join(@filters_dir, file)
        path |> File.read!() |> Jason.decode!()
      end)
    else
      []
    end
  end

  @doc """
  Carrega um filtro pelo nome.
  """
  @spec get_filter(String.t()) :: map() | nil
  def get_filter(name) do
    filename = sanitize_filename(name) <> ".json"
    path = Path.join(@filters_dir, filename)

    if File.exists?(path) do
      path |> File.read!() |> Jason.decode!()
    else
      nil
    end
  end

  @doc """
  Salva um filtro com nome específico.
  """
  @spec save_filter(String.t(), map()) :: :ok
  def save_filter(name, filter_data) do
    filename = sanitize_filename(name) <> ".json"
    path = Path.join(@filters_dir, filename)
    :ok = File.mkdir_p!(@filters_dir)
    File.write!(path, Jason.encode!(filter_data, pretty: true))
  end

  @doc """
  Exclui um filtro.
  """
  @spec delete_filter(String.t()) :: :ok
  def delete_filter(name) do
    filename = sanitize_filename(name) <> ".json"
    path = Path.join(@filters_dir, filename)
    File.rm!(path)
  rescue
    _ -> :ok
  end

  @doc """
  Aplica filtros global ou por fonte específica.
  """
  @spec apply(list(), map()) :: list()
  def apply(jobs, filters) do
    global_filters = Map.get(filters, "global", %{})
    source_filters = Map.get(filters, "by_source", %{})

    jobs
    |> apply_global_filters(global_filters)
    |> Enum.filter(fn job ->
      source = Map.get(job, "source", "")
      source_filter = Map.get(source_filters, source, %{})
      source_filter == %{} || matches_filter?(job, source_filter)
    end)
  end

  defp apply_global_filters(jobs, filters) do
    exclude_words = Map.get(filters, "exclude_words", [])
    include_words = Map.get(filters, "include_words", [])
    min_experience = Map.get(filters, "min_experience_years")
    max_applications = Map.get(filters, "max_applications")
    remote_only = Map.get(filters, "remote_only")
    require_keywords = Map.get(filters, "require_keywords", [])

    jobs
    |> reject_by_words(exclude_words)
    |> require_include_words(include_words)
    |> reject_by_experience(min_experience)
    |> reject_by_applications(max_applications)
    |> reject_by_remote(remote_only)
    |> require_keywords_match(require_keywords)
  end

  defp reject_by_words(jobs, []), do: jobs

  defp reject_by_words(jobs, words) do
    Enum.reject(jobs, fn job ->
      title = String.downcase(Map.get(job, "title", ""))
      company = String.downcase(Map.get(job, "company", ""))
      location = String.downcase(Map.get(job, "location", ""))

      Enum.any?(words, fn word ->
        w = String.downcase(word)

        String.contains?(title, w) or String.contains?(company, w) or
          String.contains?(location, w)
      end)
    end)
  end

  defp require_include_words(jobs, []), do: jobs

  defp require_include_words(jobs, words) do
    Enum.filter(jobs, fn job ->
      title = String.downcase(Map.get(job, "title", ""))
      Enum.any?(words, fn word -> String.contains?(title, String.downcase(word)) end)
    end)
  end

  defp reject_by_experience(jobs, nil), do: jobs

  defp reject_by_experience(jobs, min_years) do
    years = to_int(min_years)

    Enum.reject(jobs, fn job ->
      exp_text = String.downcase(Map.get(job, "experience", ""))

      cond do
        years <= 0 -> false
        String.contains?(exp_text, "sênior") or String.contains?(exp_text, "senior") -> false
        String.contains?(exp_text, "pleno") -> years > 2
        String.contains?(exp_text, "júnior") or String.contains?(exp_text, "junior") -> years > 0
        true -> false
      end
    end)
  end

  defp reject_by_applications(jobs, nil), do: jobs

  defp reject_by_applications(jobs, max) do
    Enum.reject(jobs, fn job ->
      apps = to_int(Map.get(job, "applications", 0))
      apps > max
    end)
  end

  defp reject_by_remote(jobs, false), do: jobs

  defp reject_by_remote(jobs, true) do
    Enum.filter(jobs, fn job ->
      location = String.downcase(Map.get(job, "location", ""))
      not String.contains?(location, "presencial") and not String.contains?(location, "on-site")
    end)
  end

  defp require_keywords_match(jobs, []), do: jobs

  defp require_keywords_match(jobs, keywords) do
    Enum.filter(jobs, fn job ->
      title = String.downcase(Map.get(job, "title", ""))
      Enum.all?(keywords, fn kw -> String.contains?(title, String.downcase(kw)) end)
    end)
  end

  defp matches_filter?(job, filter) do
    exclude_words = Map.get(filter, "exclude_words", [])
    include_words = Map.get(filter, "include_words", [])

    title = String.downcase(Map.get(job, "title", ""))

    has_exclude =
      Enum.any?(exclude_words, fn w ->
        String.contains?(title, String.downcase(w))
      end)

    has_include =
      if include_words == [] do
        true
      else
        Enum.all?(include_words, fn w ->
          String.contains?(title, String.downcase(w))
        end)
      end

    not has_exclude and has_include
  end

  defp to_int(val) when is_binary(val), do: String.to_integer(val)
  defp to_int(val), do: val

  defp sanitize_filename(name) do
    name
    |> String.downcase()
    |> String.replace(" ", "_")
    |> String.replace(~r/[^a-z0-9_]/, "")
  end
end

defmodule AutoVagas.Crawler.JobsStore do
  @moduledoc """
  Armazena vagas capturadas em memória ou arquivo.
  """

  @store_path "priv/captured_jobs.json"

  @doc """
  Salva vagas capturadas.
  """
  @spec save(list()) :: :ok
  def save(jobs) do
    data = %{
      "jobs" => jobs,
      "captured_at" => DateTime.utc_now() |> DateTime.to_iso8601()
    }

    File.write!(@store_path, Jason.encode!(data, pretty: true))
  end

  @doc """
  Carrega vagas salvas.
  """
  @spec load() :: list()
  def load do
    if File.exists?(@store_path) do
      @store_path
      |> File.read!()
      |> Jason.decode!()
      |> Map.get("jobs", [])
    else
      []
    end
  end

  @doc """
  Limpa store.
  """
  @spec clear() :: :ok
  def clear do
    File.rm!(@store_path)
  rescue
    _ -> :ok
  end
end
