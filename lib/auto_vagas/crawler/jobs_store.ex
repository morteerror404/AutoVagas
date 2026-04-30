defmodule AutoVagas.Crawler.JobsStore do
  @moduledoc """
  Gerencia armazenamento de vagas usando Mnesia.
  Interface simples para salvar/carregar vagas da tabela :jobs.
  """

  require :mnesia

  @doc """
  Salva lista de vagas na tabela Mnesia :jobs.
  """
  def save(jobs) when is_list(jobs) do
    :mnesia.transaction(fn ->
      Enum.each(jobs, fn job ->
        :mnesia.write({:jobs,
          make_ref() |> :erlang.ref_to_list() |> List.to_string(),
          Map.get(job, "search_id", ""),
          Map.get(job, "external_id", ""),
          Map.get(job, "source", ""),
          Map.get(job, "title", ""),
          Map.get(job, "company", ""),
          Map.get(job, "location", ""),
          Map.get(job, "url", ""),
          "new",
          nil,
          DateTime.utc_now()
        })
      end)
    end)
    :ok
  end

  def save(_), do: :ok

  @doc """
  Carrega todas as vagas da tabela :jobs.
  """
  def load do
    case :mnesia.transaction(fn ->
      :mnesia.foldl(fn record, acc ->
        {_, id, search_id, external_id, source, title, company, location, url, status, applied_at, created_at} = record

        job = %{
          "id" => id,
          "search_id" => search_id,
          "external_id" => external_id,
          "source" => source,
          "title" => title,
          "company" => company,
          "location" => location,
          "url" => url,
          "status" => status,
          "applied_at" => applied_at,
          "created_at" => created_at
        }
        [job | acc]
      end, [], :jobs)
    end) do
      {:atomic, jobs} -> jobs
      _ -> []
    end
  end

  @doc """
  Limpa todas as vagas da tabela :jobs.
  """
  def clear do
    :mnesia.transaction(fn ->
      :mnesia.foldl(fn record, _acc ->
        :mnesia.delete_object(record)
      end, [], :jobs)
    end)
    :ok
  end
end
