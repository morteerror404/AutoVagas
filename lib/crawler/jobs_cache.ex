defmodule AutoVagas.Crawler.JobsCache do
  @moduledoc """
  Cache distribuído de vagas usando Mnesia.
  Cada worker GenServer tem sua própria tabela para evitar contenção.
  """

  use GenServer
  require Logger
  require :mnesia

  @table_prefix :jobs_cache

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    node = Keyword.get(opts, :node, node())
    worker_id = Keyword.get(opts, :worker_id, 0)

    table_name = String.to_atom("#{@table_prefix}_#{worker_id}")

    opts = [
      attributes: [:key, :jobs, :updated_at],
      type: :set
    ]

    opts = add_storage_opt(opts, node)

    :mnesia.create_table(table_name, opts)
    :mnesia.wait_for_tables([table_name], 5000)

    {:ok, %{table_name: table_name, worker_id: worker_id}}
  end

  defp add_storage_opt(opts, node) do
    storage_type = if node == :nonode@nohost do
      :ram_copies
    else
      :disc_copies
    end

    Keyword.put(opts, storage_type, [node])
  end

  @doc """
  Armazena vagas para uma chave única.
  """
  def put(key, jobs) do
    GenServer.call(__MODULE__, {:put, key, jobs})
  end

  @doc """
  Busca vagas por chave.
  """
  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  @doc """
  Remove vagas antigas (mais que X dias).
  """
  def cleanup(max_age_days) do
    GenServer.call(__MODULE__, {:cleanup, max_age_days})
  end

  @doc """
  Lista todas as chaves no cache.
  """
  def all_keys do
    GenServer.call(__MODULE__, :all_keys)
  end

  def size do
    GenServer.call(__MODULE__, :size)
  end

  # GenServer callbacks

  def handle_call({:put, key, jobs}, _from, state) do
    table = state.table_name

    :mnesia.transaction(fn ->
      :mnesia.write({table, key, jobs, DateTime.utc_now()})
    end)

    {:reply, :ok, state}
  end

  def handle_call({:get, key}, _from, state) do
    table = state.table_name

    result = :mnesia.transaction(fn ->
      :mnesia.read(table, key)
    end)
    
    jobs = case result do
      {:atomic, [{_, ^key, jobs, _updated_at}]} -> jobs
      _ -> []
    end

    {:reply, jobs, state}
  end

  def handle_call({:cleanup, max_age_days}, _from, state) do
    table = state.table_name
    cutoff = DateTime.add(DateTime.utc_now(), -max_age_days * 86400, :second)

    :mnesia.transaction(fn ->
      :mnesia.foldl(fn record, acc ->
        case record do
          {_, key, jobs, updated_at} when updated_at < cutoff ->
            :mnesia.delete_object({table, key, jobs, updated_at})
            acc

          _ ->
            acc
        end
      end, [], table)
    end)

    {:reply, :ok, state}
  end

  def handle_call(:all_keys, _from, state) do
    table = state.table_name

    result = :mnesia.transaction(fn ->
      :mnesia.foldl(fn {_, key, _, _}, acc -> [key | acc] end, [], table)
    end)

    keys = case result do
      {:atomic, keys} -> keys
      _ -> []
    end

    {:reply, keys, state}
  end

  def handle_call(:size, _from, state) do
    table = state.table_name

    result = :mnesia.transaction(fn ->
      :mnesia.foldl(fn _, acc -> acc + 1 end, 0, table)
    end)

    size = case result do
      {:atomic, size} -> size
      _ -> 0
    end

    {:reply, size, state}
  end
end
