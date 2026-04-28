defmodule AutoVagas.Mnesia.SearchManager do
  @moduledoc """
  Gerencia múltiplas buscas simultâneas usando Mnesia.
  Cada busca pode ter parâmetros diferentes (keywords, sources, location, filters).
  """

  require Logger
  require :mnesia

  @doc """
  Cria uma nova busca com parâmetros específicos.
  Retorna o ID da busca criada.
  """
  def create_search(keywords, sources, opts \\ []) do
    id = generate_search_id()
    now = DateTime.utc_now()

    search = %{
      id: id,
      keywords: keywords,
      sources: sources,
      location: Keyword.get(opts, :location, "Brazil"),
      filters: Keyword.get(opts, :filters, %{}),
      status: "active",
      created_at: now,
      updated_at: now
    }

    :mnesia.transaction(fn ->
      :mnesia.write({:searches, id, search})
    end)

    Logger.info("Created search #{id} for keywords: #{inspect(keywords)}")
    {:ok, id}
  end

  @doc """
  Lista todas as buscas ativas.
  """
  def list_searches do
    {:atomic, searches} = :mnesia.transaction(fn ->
      :mnesia.foldl(fn record, acc ->
        {_table, id, search} = record
        [{id, search} | acc]
      end, [], :searches)
    end)

    searches
  end

  @doc """
  Obtém uma busca específica pelo ID.
  """
  def get_search(id) do
    {:atomic, result} = :mnesia.transaction(fn ->
      :mnesia.read(:searches, id)
    end)

    case result do
      [{_table, ^id, search}] -> {:ok, search}
      _ -> {:error, :not_found}
    end
  end

  @doc """
  Atualiza o status de uma busca.
  """
  def update_search_status(id, status) do
    case get_search(id) do
      {:ok, search} ->
        updated = Map.put(search, :status, status)
        |> Map.put(:updated_at, DateTime.utc_now())

        :mnesia.transaction(fn ->
          :mnesia.write({:searches, id, updated})
        end)

        {:ok, updated}

      error ->
        error
    end
  end

  @doc """
  Remove uma busca e suas vagas associadas.
  """
  def delete_search(id) do
    :mnesia.transaction(fn ->
      :mnesia.delete({:searches, id})
      delete_jobs_by_search(id)
    end)

    Logger.info("Deleted search #{id}")
    :ok
  end

  @doc """
  Adiciona uma vaga a uma busca específica.
  """
  def add_job(search_id, job_data) do
    id = generate_job_id()
    now = DateTime.utc_now()

    job = Map.merge(job_data, %{
      id: id,
      search_id: search_id,
      status: "pending",
      applied_at: nil,
      created_at: now
    })

    :mnesia.transaction(fn ->
      :mnesia.write({:jobs, id, job})
    end)

    {:ok, id}
  end

  @doc """
  Lista vagas de uma busca específica.
  """
  def list_jobs(search_id) do
    {:atomic, jobs} = :mnesia.transaction(fn ->
      :mnesia.foldl(fn record, acc ->
        {_table, id, job} = record
        if job.search_id == search_id do
          [{id, job} | acc]
        else
          acc
        end
      end, [], :jobs)
    end)

    jobs
  end

  @doc """
  Atualiza o status de uma vaga.
  """
  def update_job_status(job_id, status) do
    {:atomic, result} = :mnesia.transaction(fn ->
      :mnesia.read(:jobs, job_id)
    end)

    case result do
      [{_table, ^job_id, job}] ->
        updated = Map.put(job, :status, status)
        |> Map.put(:updated_at, DateTime.utc_now())

        :mnesia.transaction(fn ->
          :mnesia.write({:jobs, job_id, updated})
        end)

        {:ok, updated}

      _ ->
        {:error, :not_found}
    end
  end

  defp delete_jobs_by_search(search_id) do
    {:atomic, jobs} = :mnesia.transaction(fn ->
      :mnesia.foldl(fn record, acc ->
        {_table, id, job} = record
        if job.search_id == search_id do
          [{id, job} | acc]
        else
          acc
        end
      end, [], :jobs)
    end)

    Enum.each(jobs, fn {id, _} ->
      :mnesia.delete({:jobs, id})
    end)
  end

  defp generate_search_id do
    "search_#{:crypto.hash(:sha256, "#{DateTime.utc_now()}_#{:rand.uniform(10000)}") |> Base.encode16(case: :lower)}"
    |> String.slice(0, 16)
  end

  defp generate_job_id do
    "job_#{:crypto.hash(:sha256, "#{DateTime.utc_now()}_#{:rand.uniform(10000)}") |> Base.encode16(case: :lower)}"
    |> String.slice(0, 16)
  end

  @doc """
  Obtém uma vaga específica pelo ID.
  """
  def get_job(job_id) do
    {:atomic, result} = :mnesia.transaction(fn ->
      :mnesia.read(:jobs, job_id)
    end)

    case result do
      [{_table, ^job_id, job}] -> {:ok, job}
      _ -> {:error, :not_found}
    end
  end

  @doc """
  Atualiza uma vaga completa.
  """
  def update_job(job_id, job_data) do
    :mnesia.transaction(fn ->
      :mnesia.write({:jobs, job_id, job_data})
    end)

    {:ok, job_data}
  end
end
