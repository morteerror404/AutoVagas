defmodule AutoVagasWeb.JobSearchLive do
  use AutoVagasWeb, :live_view

  alias AutoVagas.Crawler.{Adapter, JobsStore, AuthSession, Filter}
  alias AutoVagas.Crawler.UserConfig

  @type search_params :: %{
          keywords: String.t(),
          location: String.t(),
          source: String.t(),
          time_posted: String.t(),
          work_type: String.t(),
          include_words: String.t(),
          exclude_words: String.t(),
          min_experience: String.t(),
          remote_only: boolean()
        }

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="max-w-6xl mx-auto p-6">
        <!-- Header -->
        <div class="flex flex-col md:flex-row justify-between items-start md:items-center mb-6 gap-4">
          <div>
            <h1 class="text-3xl font-bold text-base-content">AutoVagas</h1>
            <p class="text-base-content/60">Busca automatizada de vagas de emprego</p>
          </div>
          <div class="flex gap-2">
            <button phx-click="clear_all" class="btn btn-error btn-sm">
              Limpar Todas
            </button>
            <.link navigate="/configuracoes" class="btn btn-ghost btn-sm">
              Configurações
            </.link>
          </div>
        </div>

        <!-- Search Form -->
        <div class="card bg-base-200 shadow-sm mb-6">
          <div class="card-body">
            <.form for={@form} id="search-form" phx-submit="search" class="space-y-4">
              <!-- Main Search -->
              <div class="form-control">
                <label class="label">
                  <span class="label-text font-medium">Palavras-chave *</span>
                </label>
                <.input
                  field={@form[:keywords]}
                  type="text"
                  placeholder="ex: desenvolvedor elixir, analista..."
                  class="w-full input-bordered"
                />
              </div>

              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div class="form-control">
                  <label class="label">
                    <span class="label-text font-medium">Localização</span>
                  </label>
                  <.input
                    field={@form[:location]}
                    type="text"
                    placeholder="Brazil"
                    class="w-full input-bordered"
                  />
                </div>

                <div class="form-control">
                  <label class="label">
                    <span class="label-text font-medium">Fonte</span>
                  </label>
                  <.input
                    field={@form[:source]}
                    type="select"
                    options={[
                      {"Todas", "all"},
                      {"LinkedIn", "linkedin"},
                      {"Indeed", "indeed"},
                      {"Gupy", "gupy"}
                    ]}
                    class="w-full select-bordered"
                  />
                </div>
              </div>

              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div class="form-control">
                  <label class="label">
                    <span class="label-text font-medium">Tempo de postagem</span>
                  </label>
                  <.input
                    field={@form[:time_posted]}
                    type="select"
                    options={[
                      {"Última hora", "r3600"},
                      {"Últimas 24 horas", "r86400"},
                      {"Última semana", "r604800"},
                      {"Último mês", "r2592000"}
                    ]}
                    class="w-full select-bordered"
                  />
                </div>

                <div class="form-control">
                  <label class="label">
                    <span class="label-text font-medium">Tipo de trabalho</span>
                  </label>
                  <.input
                    field={@form[:work_type]}
                    type="select"
                    options={[
                      {"Todos", "1%2C2%2C3"},
                      {"Remoto", "2"},
                      {"Presencial", "1"},
                      {"Híbrido", "3"}
                    ]}
                    class="w-full select-bordered"
                  />
                </div>
              </div>

              <!-- Advanced Filters (Collapse) -->
              <div class="collapse bg-base-300 border border-base-300 rounded-lg">
                <input type="checkbox" class="peer" />
                <div class="collapse-title font-medium text-base-content">
                  Filtros Avançados
                </div>
                <div class="collapse-content">
                  <div class="space-y-4 pt-2">
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <div class="form-control">
                        <label class="label">
                          <span class="label-text font-medium">Palavras para incluir</span>
                        </label>
                        <.input
                          field={@form[:include_words]}
                          type="text"
                          placeholder="ex: python, docker, aws"
                          class="w-full input-bordered"
                        />
                      </div>

                      <div class="form-control">
                        <label class="label">
                          <span class="label-text font-medium">Palavras para excluir</span>
                        </label>
                        <.input
                          field={@form[:exclude_words]}
                          type="text"
                          placeholder="ex: estagio, junior"
                          class="w-full input-bordered"
                        />
                      </div>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <div class="form-control">
                        <label class="label">
                          <span class="label-text font-medium">Experiência mínima (anos)</span>
                        </label>
                        <.input
                          field={@form[:min_experience]}
                          type="number"
                          min="0"
                          class="w-full input-bordered"
                        />
                      </div>

                      <div class="form-control">
                        <label class="label">
                          <span class="label-text font-medium">Máximo de aplicações</span>
                        </label>
                        <.input
                          field={@form[:max_applications]}
                          type="number"
                          min="0"
                          class="w-full input-bordered"
                        />
                      </div>
                    </div>

                    <div class="form-control">
                      <label class="label cursor-pointer justify-start gap-4">
                        <.input
                          field={@form[:remote_only]}
                          type="checkbox"
                          class="checkbox checkbox-primary"
                        />
                        <span class="label-text">Apenas vagas remotas</span>
                      </label>
                    </div>
                  </div>
                </div>
              </div>

              <button
                type="submit"
                class="btn btn-primary w-full"
                disabled={@loading}
              >
                <span :if={@loading} class="loading loading-spinner loading-sm mr-2"></span>
                {if @loading, do: "Buscando...", else: "Buscar Vagas"}
              </button>
            </.form>
          </div>
        </div>

        <!-- Bulk Actions -->
        <div :if={@displayed_jobs != []} class="bg-base-200 rounded-lg p-4 mb-6">
          <div class="flex flex-col md:flex-row gap-4 items-start md:items-center">
            <div class="flex gap-2">
              <button phx-click="select_all" class="btn btn-sm btn-outline">
                Selecionar Todas
              </button>
              <button phx-click="deselect_all" class="btn btn-sm btn-outline">
                Desmarcar
              </button>
              <button
                phx-click="delete_selected"
                class={"btn btn-sm btn-error " <> if(MapSet.size(@selected_ids) == 0, do: "btn-disabled", else: "")}
                disabled={MapSet.size(@selected_ids) == 0}
              >
                Excluir <%= MapSet.size(@selected_ids) %> Selecionadas
              </button>
            </div>

            <!-- Search in Results -->
            <.form for={@search_form} phx-change="search_jobs" class="flex-1">
              <div class="input-group">
                <input
                  type="text"
                  name="q"
                  placeholder="Buscar nos resultados..."
                  value={@search_query}
                  class="input input-bordered w-full"
                />
                <button class="btn btn-square btn-ghost">
                  <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                  </svg>
                </button>
              </div>
            </.form>
          </div>

          <!-- Filters Panel -->
          <div :if={@show_filters} class="mt-4 pt-4 border-t border-base-300">
            <.form for={@filter_form} phx-change="apply_filter" class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div class="form-control">
                <label class="label">
                  <span class="label-text text-xs">Palavras para EXCLUIR</span>
                </label>
                <input
                  type="text"
                  name="exclude_words"
                  placeholder="separadas por vírgula"
                  class="input input-bordered input-sm w-full"
                />
              </div>
              <div class="form-control">
                <label class="label">
                  <span class="label-text text-xs">Palavras para INCLUIR (obriga)</span>
                </label>
                <input
                  type="text"
                  name="include_words"
                  placeholder="separadas por vírgula"
                  class="input input-bordered input-sm w-full"
                />
              </div>
            </.form>
          </div>

          <div class="mt-2">
            <button phx-click="toggle_filters" class={"btn btn-sm " <> if(@show_filters, do: "btn-active", else: "btn-ghost")}>
              Filtros
            </button>
          </div>
        </div>

        <!-- Loading State -->
        <div :if={@loading} class="text-center py-12">
          <span class="loading loading-lg loading-spinner text-primary"></span>
          <p class="mt-4 text-base-content/60">Buscando vagas...</p>
        </div>

        <!-- Results -->
        <div :if={@displayed_jobs != [] and not @loading} class="space-y-3">
          <h2 class="text-xl font-semibold text-base-content mb-4">
            <%= length(@displayed_jobs) %> vagas encontradas
          </h2>

          <div class="space-y-3" id="jobs" phx-update="stream">
            <div
              :for={{id, job} <- @streams.jobs}
              id={id}
              class="card bg-base-200 shadow-sm hover:shadow-md transition-shadow"
            >
              <div class="card-body p-4">
                <div class="flex items-start gap-4">
                  <input
                    type="checkbox"
                    checked={job.selected}
                    phx-click="toggle_select"
                    phx-value={job.external_id}
                    class="checkbox checkbox-sm mt-1"
                  />

                  <div class="flex-1">
                    <div class="flex justify-between items-start">
                      <div>
                        <h3 class="card-title text-base-content"><%= job.title %></h3>
                        <p class="text-sm text-base-content/70"><%= job.company %></p>
                        <p class="text-xs text-base-content/50"><%= job.location %></p>
                      </div>
                      <div class="badge badge-primary"><%= job.source %></div>
                    </div>

                    <div class="flex gap-2 mt-3">
                      <a href={job.url} target="_blank" class="btn btn-primary btn-xs">
                        Ver Original
                      </a>
                      <button phx-click="toggle_details" phx-value={job.external_id} class="btn btn-ghost btn-xs">
                        <%= if Map.get(@expanded, job.external_id, false), do: "Ocultar", else: "Detalhes" %>
                      </button>
                    </div>

                    <div
                      :if={Map.get(@expanded, job.external_id, false)}
                      class="mt-3 p-3 bg-base-300 rounded text-sm"
                    >
                      <p class="whitespace-pre-wrap"><%= job.description || "Descrição não disponível" %></p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Empty State -->
        <div
          :if={@displayed_jobs == [] and not @loading and @searched}
          class="text-center py-16"
        >
          <div class="text-6xl mb-4">🔍</div>
          <p class="text-base-content/50">Nenhuma vaga encontrada.</p>
          <p class="text-sm text-base-content/40 mt-2">Tente buscar com outros termos.</p>
        </div>

        <div
          :if={@displayed_jobs == [] and not @loading and not @searched}
          class="text-center py-16"
        >
          <div class="text-6xl mb-4">📭</div>
          <p class="text-base-content/50">Use o formulário acima para buscar vagas.</p>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    user_config = UserConfig.load()
    filters = Map.get(user_config, "filters", %{})
    global_filters = Map.get(filters, "global", %{})

    form =
      to_form(%{
        "keywords" => "",
        "location" => "Brazil",
        "source" => "linkedin",
        "time_posted" => "r86400",
        "work_type" => "1%2C2%2C3",
        "include_words" => Enum.join(Map.get(global_filters, "include_words", []), ", "),
        "exclude_words" => Enum.join(Map.get(global_filters, "exclude_words", []), ", "),
        "min_experience" => Map.get(global_filters, "min_experience_years", ""),
        "max_applications" => Map.get(global_filters, "max_applications", ""),
        "remote_only" => Map.get(global_filters, "remote_only", false)
      })

    search_form = to_form(%{"q" => ""})

    filter_form =
      to_form(%{
        "exclude_words" => "",
        "include_words" => "",
        "remote_only" => false
      })

    jobs =
      JobsStore.load()
      |> Enum.map(fn job ->
        job
        |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
        |> Map.put(:selected, false)
      end)

    socket =
      socket
      |> assign(:active_page, "buscar")
      |> assign(form: form, search_form: search_form, filter_form: filter_form)
      |> assign(jobs: jobs, displayed_jobs: jobs, search_query: "", selected_ids: MapSet.new())
      |> assign(expanded: %{}, show_filters: false, loading: false, searched: false)
      |> stream_configure(:jobs, dom_id: &"job-#{&1.external_id}")

    {:ok, socket}
  end

  def handle_event("search", %{"keywords" => keywords} = params, socket) do
    if keywords == "" do
      {:noreply, socket}
    else
      socket = assign(socket, loading: true, searched: true)
      Process.send(self(), {:run_search, params}, [])
      {:noreply, socket}
    end
  end

  def handle_info({:run_search, params}, socket) do
    keywords = params["keywords"]
    location = Map.get(params, "location", "Brazil")
    source = Map.get(params, "source", "linkedin")
    time_posted = Map.get(params, "time_posted", "r86400")
    work_type = Map.get(params, "work_type", "1%2C2%2C3")

    sources = if source == "all", do: ["linkedin", "indeed", "gupy"], else: [source]

    user_info = UserConfig.load()

    all_jobs =
      sources
      |> Enum.map(&Adapter.adapter_for/1)
      |> Enum.reject(&is_nil/1)
      |> Enum.flat_map(fn adapter ->
        keywords_list = String.split(keywords, ",") |> Enum.map(&String.trim/1)

        urls =
          adapter.build_urls(keywords_list,
            location: location,
            time_posted: time_posted,
            work_type: work_type
          )

        jobs = fetch_jobs(adapter, urls)

        # Apply filters using Filter module
        AutoVagas.Crawler.Filter.apply(jobs, Map.get(user_info, "filters", %{}))
      end)
      |> Enum.uniq_by(fn job -> job["external_id"] end)
      |> Enum.map(&Map.put(&1, "selected", false))

    existing = JobsStore.load()
    updated = (existing ++ all_jobs) |> Enum.uniq_by(fn job -> job["external_id"] end)
    JobsStore.save(updated)

    socket =
      socket
      |> assign(loading: false, jobs: updated, displayed_jobs: updated)
      |> stream(:jobs, updated, reset: true)

    {:noreply, socket}
  end

  def handle_event("search_jobs", %{"q" => query}, socket) do
    jobs = socket.assigns.jobs
    query = String.downcase(query)

    filtered =
      if query == "" do
        jobs
      else
        Enum.filter(jobs, fn job ->
          title = String.downcase(Map.get(job, :title, ""))
          company = String.downcase(Map.get(job, :company, ""))
          location = String.downcase(Map.get(job, :location, ""))

          String.contains?(title, query) or String.contains?(company, query) or
            String.contains?(location, query)
        end)
      end

    {:noreply, socket |> assign(displayed_jobs: filtered, search_query: query)}
  end

  def handle_event("toggle_select", %{"value" => id}, socket) do
    selected =
      if id in socket.assigns.selected_ids do
        MapSet.delete(socket.assigns.selected_ids, id)
      else
        MapSet.put(socket.assigns.selected_ids, id)
      end

    jobs =
      Enum.map(socket.assigns.jobs, fn job ->
        if job[:external_id] == id do
          Map.put(job, :selected, id in selected)
        else
          job
        end
      end)

    {:noreply, socket |> assign(jobs: jobs, selected_ids: selected)}
  end

  def handle_event("select_all", _, socket) do
    ids = MapSet.new(Enum.map(socket.assigns.jobs, & &1[:external_id]))
    jobs = Enum.map(socket.assigns.jobs, fn job -> Map.put(job, :selected, true) end)
    {:noreply, socket |> assign(jobs: jobs, selected_ids: ids)}
  end

  def handle_event("deselect_all", _, socket) do
    jobs = Enum.map(socket.assigns.jobs, fn job -> Map.put(job, :selected, false) end)
    {:noreply, socket |> assign(jobs: jobs, selected_ids: MapSet.new())}
  end

  def handle_event("delete_selected", _, socket) do
    ids = socket.assigns.selected_ids
    remaining = Enum.reject(socket.assigns.jobs, fn job -> job[:external_id] in ids end)

    JobsStore.save(remaining)

    remaining_with_selection = Enum.map(remaining, &Map.put(&1, :selected, false))

    {:noreply,
     socket
     |> assign(
       jobs: remaining_with_selection,
       displayed_jobs: remaining_with_selection,
       selected_ids: MapSet.new()
     )}
  end

  def handle_event("clear_all", _, socket) do
    JobsStore.clear()
    {:noreply, socket |> assign(jobs: [], displayed_jobs: [], selected_ids: MapSet.new())}
  end

  def handle_event("toggle_filters", _, socket) do
    {:noreply, assign(socket, show_filters: not socket.assigns.show_filters)}
  end

  def handle_event("toggle_details", %{"value" => id}, socket) do
    expanded = Map.put(socket.assigns.expanded, id, not socket.assigns.expanded[id])
    {:noreply, assign(socket, expanded: expanded)}
  end

  def handle_event("apply_filter", params, socket) do
    filters = %{
      "global" => %{
        "exclude_words" => parse_list(params["exclude_words"]),
        "include_words" => parse_list(params["include_words"]),
        "remote_only" => params["remote_only"] == "true"
      }
    }

    filtered = Filter.apply(socket.assigns.jobs, filters)

    {:noreply, socket |> assign(displayed_jobs: filtered)}
  end

  defp fetch_jobs(adapter, urls) do
    source = adapter_source(adapter)

    urls
    |> Enum.map(fn {_keyword, url} ->
      Task.async(fn ->
        cookies = AuthSession.get_cookies(source)
        case fetch_with_cookies(url, cookies) do
          %{status: 200, body: body} ->
            adapter.parse(body)

          _ ->
            []
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

  defp fetch_with_cookies(url, [] = _cookies) do
    Req.get!(url, follow_redirects: true)
  end

  defp fetch_with_cookies(url, cookies) do
    cookie_header =
      cookies
      |> Enum.map(fn %{"name" => name, "value" => value} -> "#{name}=#{value}" end)
      |> Enum.join("; ")

    Req.get!(url,
      follow_redirects: true,
      headers: [{"cookie", cookie_header}]
    )
  end

  defp adapter_source(AutoVagas.Crawler.Sites.LinkedIn), do: "linkedin"
  defp adapter_source(AutoVagas.Crawler.Sites.Indeed), do: "indeed"
  defp adapter_source(AutoVagas.Crawler.Sites.Gupy), do: "gupy"
  defp adapter_source(_), do: nil

  defp parse_list(""), do: []

  defp parse_list(s) when is_binary(s),
    do: s |> String.split(",") |> Enum.map(&String.trim/1) |> Enum.reject(&(&1 == ""))

  defp parse_list(l), do: l
end
