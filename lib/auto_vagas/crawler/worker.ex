defmodule AutoVagas.Crawler.Worker do
  @moduledoc """
  Worker GenServer que executa crawling para uma search_id específica.
  Cada usuário pode ter múltiplos workers rodando em paralelo.
  """

  use GenServer
  require Logger
  alias AutoVagas.Crawler.Adapter
  alias AutoVagas.Mnesia.SearchManager
  alias AutoVagas.Notifications.Channels

  @doc """
  Inicia um novo worker de crawling.
  """
  def start_link(search_id) do
    name = :"crawler_worker_#{search_id}"
    GenServer.start_link(__MODULE__, search_id, name: name)
  end

  def init(search_id) do
    Logger.info("Worker started for search: #{search_id}")

    case SearchManager.get_search(search_id) do
      {:ok, config} ->
        {:ok, %{search_id: search_id, config: config, status: :idle}}

      {:error, :not_found} ->
        {:stop, :search_not_found}
    end
  end

  @doc """
  Inicia o crawling para a configuração do worker.
  """
  def run_crawl(server) do
    GenServer.cast(server, :run_crawl)
  end

  def handle_cast(:run_crawl, %{status: :running} = state) do
    {:noreply, state}
  end

  def handle_cast(:run_crawl, %{search_id: search_id, config: config} = state) do
    Logger.info("Starting crawl for search #{search_id}")
    SearchManager.update_search_status(search_id, "running")

    jobs = execute_crawl(config)

    state = Map.put(state, :status, :idle)
    {:noreply, state, {:continue, {:save_jobs, jobs, search_id}}}
  end

  def handle_continue({:save_jobs, jobs, search_id}, state) do
    Enum.each(jobs, fn job ->
      SearchManager.add_job(search_id, job)
    end)

    broadcast_jobs(jobs, search_id)

    user_info = AutoVagas.Crawler.UserConfig.load()
    if Channels.has_active_channels?(user_info) do
      Enum.each(jobs, fn job ->
        Channels.notify_new_job(job, user_info)
      end)
    end

    # Inicia processo de inscrição automática
    case AutoVagas.Automation.Automation.start_session() do
      {:ok, automation_session} ->
        Logger.info("Iniciando inscrições automáticas")
        Enum.each(jobs, fn job ->
          if job["source"] == "linkedin" do
            AutoVagas.Automation.Automation.apply_to_job(automation_session, job["url"], user_info)
          end
        end)
        AutoVagas.Automation.Automation.end_session(automation_session)

      {:error, reason} ->
        Logger.warning("Não foi possível iniciar sessão de automação: #{inspect(reason)}")
    end

    SearchManager.update_search_status(search_id, "completed")

    {:noreply, state}
  end

  defp execute_crawl(config) do
    sources = config.sources
    keywords = config.keywords |> String.split(",") |> Enum.map(&String.trim/1)

    sources
    |> Enum.map(fn src ->
      case Adapter.adapter_for(src) do
        nil -> nil
        adapter -> {src, adapter}
      end
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.flat_map(fn {_src, adapter} ->
      urls = adapter.build_urls(
        keywords,
        location: config.location,
        time_posted: Map.get(config, :time_posted, "r86400"),
        work_type: Map.get(config, :work_type, "all")
      )
      fetch_jobs(adapter, urls)
    end)
    |> Enum.uniq_by(fn job -> job["external_id"] end)
  end

  defp fetch_jobs(adapter, urls) do
    urls
    |> Enum.map(fn {_keyword, url} ->
      Task.async(fn ->
        case Req.get(url, follow_redirects: true) do
          {:ok, %{status: 200, body: body}} -> adapter.parse(body)
          _ -> []
        end
      end)
    end)
    |> Task.await_many(30_000)
    |> Enum.flat_map(fn
      jobs when is_list(jobs) -> jobs
      {:ok, jobs} when is_list(jobs) -> jobs
      _ -> []
    end)
  end

  defp broadcast_jobs(jobs, search_id) do
    Phoenix.PubSub.broadcast(AutoVagas.PubSub, "jobs:#{search_id}", {:new_jobs, jobs})
  end
end
