defmodule AutoVagasWeb.JobsLive do
  use AutoVagasWeb, :live_view

  alias AutoVagas.Crawler.{Filter, Engine}

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="min-h-screen bg-base-100">
        <div class="bg-base-200 border-b border-base-300 px-6 py-4">
          <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
            <div>
              <h1 class="text-2xl font-bold text-base-content">Dashboard - Automação de Vagas</h1>
              <p class="text-base-content/60 text-sm">Visão global das regras e buscas</p>
            </div>
            <div class="flex gap-2">
              <button phx-click="new_rule" class="btn btn-primary btn-sm">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                </svg>
                Nova Regra
              </button>
            </div>
          </div>
        </div>

        <div class="p-6 max-w-7xl mx-auto">
          <!-- Stats Cards -->
          <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
            <div class="stat bg-base-200 shadow-sm rounded-lg p-4">
              <div class="stat-title text-xs">Total de Regras</div>
              <div class="stat-value text-2xl"><%= length(@rules) %></div>
              <div class="stat-desc"><%= length(Enum.filter(@rules, & &1["active"])) %> ativas</div>
            </div>

            <div class="stat bg-base-200 shadow-sm rounded-lg p-4">
              <div class="stat-title text-xs">Buscas Salvas</div>
              <div class="stat-value text-2xl"><%= length(@saved_searches) %></div>
              <div class="stat-desc">Configuradas</div>
            </div>

            <div class="stat bg-base-200 shadow-sm rounded-lg p-4">
              <div class="stat-title text-xs">Vagas Capturadas</div>
              <div class="stat-value text-2xl"><%= length(@jobs) %></div>
              <div class="stat-desc"><%= length(@displayed_jobs) %> exibidas</div>
            </div>

            <div class="stat bg-base-200 shadow-sm rounded-lg p-4">
              <div class="stat-title text-xs">Status</div>
              <div class="stat-value text-2xl">
                <%= if @loading do %>
                  <span class="loading loading-spinner loading-sm text-primary"></span>
                <% else %>
                  <span class="text-success">Online</span>
                <% end %>
              </div>
              <div class="stat-desc">Sistema ativo</div>
            </div>
          </div>

          <!-- Main Grid Layout (Zabbix Dashboard style) -->
          <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

            <!-- Left Column: Rules Panel -->
            <div class="lg:col-span-2">
              <div class="bg-base-200 rounded-lg shadow-sm">
                <div class="p-4 border-b border-base-300">
                  <h2 class="text-lg font-semibold text-base-content">Regras de Automação</h2>
                </div>

                <div class="p-4">
                  <div :if={@rules == []} class="text-center py-8 text-base-content/50">
                    <div class="text-4xl mb-2">🤖</div>
                    <p class="text-sm">Nenhuma regra configurada</p>
                  </div>

                  <div :for={rule <- @rules} class="mb-3 p-4 bg-base-100 rounded border border-base-300 hover:shadow-md transition-shadow">
                    <div class="flex justify-between items-start">
                      <div class="flex-1">
                        <div class="flex items-center gap-2 mb-2">
                          <div class={"w-2 h-2 rounded-full " <> if(rule["active"], do: "bg-success", else: "bg-base-300")}></div>
                          <h3 class="font-semibold text-base-content"><%= rule["name"] || "Sem nome" %></h3>
                        </div>
                        <p class="text-sm text-base-content/70 mb-2">
                          <strong>Keywords:</strong> <%= Enum.join(rule["keywords"] || [], ", ") %>
                        </p>
                        <div class="flex gap-2">
                          <span class="badge badge-sm"><%= rule["source"] || "linkedin" %></span>
                          <span class={"badge badge-sm " <> if(rule["active"], do: "badge-success", else: "badge-ghost")}>
                            <%= if rule["active"], do: "Ativa", else: "Inativa" %>
                          </span>
                          <span class="badge badge-sm"><%= rule["schedule"] || "diária" %></span>
                        </div>
                      </div>
                      <div class="flex gap-1">
                        <button phx-click="toggle_rule" phx-value={rule["id"]} class="btn btn-xs btn-ghost">
                          <%= if rule["active"], do: "⏸ Desativar", else: "▶ Ativar" %>
                        </button>
                        <button phx-click="delete_rule" phx-value={rule["id"]} class="btn btn-xs btn-error btn-ghost">
                          ✕
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Right Column: Searches & Quick Actions -->
            <div class="space-y-6">
              <!-- Saved Searches Widget -->
              <div class="bg-base-200 rounded-lg shadow-sm">
                <div class="p-4 border-b border-base-300">
                  <h2 class="text-lg font-semibold text-base-content">Buscas Salvas</h2>
                </div>
                <div class="p-4">
                  <div :for={search <- @saved_searches} class="mb-2 p-3 bg-base-100 rounded border border-base-300">
                    <div class="flex justify-between items-center">
                      <div>
                        <p class="font-medium text-sm text-base-content"><%= search["keywords"] %></p>
                        <p class="text-xs text-base-content/50"><%= search["location"] || "Brazil" %></p>
                      </div>
                      <button phx-click="run_search" phx-value={search["id"]} class="btn btn-xs btn-primary">
                        Executar
                      </button>
                    </div>
                  </div>
                  <div :if={@saved_searches == []} class="text-center py-4 text-base-content/50 text-sm">
                    Nenhuma busca salva
                  </div>
                </div>
              </div>

              <!-- Quick Search Widget -->
              <div class="bg-base-200 rounded-lg shadow-sm">
                <div class="p-4 border-b border-base-300">
                  <h2 class="text-lg font-semibold text-base-content">Busca Rápida</h2>
                </div>
                <div class="p-4">
                  <.form for={@search_form} phx-submit="search">
                    <div class="form-control mb-3">
                      <label class="label"><span class="label-text text-xs">Palavras-chave</span></label>
                      <input
                        type="text"
                        name="keywords"
                        class="input input-sm input-bordered w-full"
                        placeholder="Ex: Elixir, Python"
                        value={@search_form[:keywords].value}
                      />
                    </div>
                    <div class="form-control mb-3">
                      <label class="label"><span class="label-text text-xs">Localização</span></label>
                      <input
                        type="text"
                        name="location"
                        class="input input-sm input-bordered w-full"
                        placeholder="Brazil, Remote"
                        value={@search_form[:location].value}
                      />
                    </div>
                    <button type="submit" class="btn btn-sm btn-primary w-full" disabled={@loading}>
                      <%= if @loading do %>
                        <span class="loading loading-spinner loading-xs"></span>
                      <% else %>
                        Buscar Vagas
                      <% end %>
                    </button>
                  </.form>
                </div>
              </div>
            </div>
          </div>

          <!-- Jobs List (Bottom Panel) -->
          <div class="mt-6">
            <div class="bg-base-200 rounded-lg shadow-sm">
              <div class="p-4 border-b border-base-300">
                <div class="flex justify-between items-center">
                  <h2 class="text-lg font-semibold text-base-content">
                    Vagas Capturadas
                    <span class="text-sm font-normal text-base-content/60">
                      (<%= length(@displayed_jobs) %> de <%= length(@jobs) %>)
                    </span>
                  </h2>
                  <div class="flex gap-2">
                    <input
                      type="text"
                      phx-change="filter_jobs"
                      name="q"
                      value={@search_form[:q].value}
                      placeholder="Filtrar..."
                      class="input input-xs input-bordered w-48"
                    />
                    <button phx-click="clear_all" class="btn btn-xs btn-error">Limpar</button>
                  </div>
                </div>
              </div>

              <div class="p-4">
                <div :if={@loading} class="text-center py-8">
                  <span class="loading loading-lg loading-spinner text-primary"></span>
                  <p class="mt-2 text-base-content/60">Buscando vagas...</p>
                </div>

                <div :if={not @loading and @searched and @displayed_jobs == []} class="text-center py-8 text-base-content/50">
                  <p>Nenhuma vaga encontrada</p>
                </div>

                <div :if={@displayed_jobs != []} class="space-y-2 max-h-96 overflow-y-auto">
                  <div :for={job <- @displayed_jobs} class="p-3 bg-base-100 rounded border border-base-300 hover:bg-base-300 transition-colors">
                    <div class="flex items-start gap-3">
                      <input
                        type="checkbox"
                        checked={job.selected}
                        phx-click="toggle_select"
                        phx-value={job.external_id}
                        class="checkbox checkbox-xs mt-1"
                      />
                      <div class="flex-1">
                        <div class="flex justify-between">
                          <h3 class="font-medium text-sm text-base-content"><%= job.title %></h3>
                          <span class="badge badge-xs badge-primary"><%= job.source %></span>
                        </div>
                        <p class="text-xs text-base-content/70"><%= job.company %> - <%= job.location %></p>
                      </div>
                      <div class="flex gap-1">
                        <a href={job.url} target="_blank" class="btn btn-xs btn-ghost">Ver</a>
                        <button phx-click="toggle_details" phx-value={job.external_id} class="btn btn-xs btn-ghost">
                          <%= if(Map.get(@expanded, job.external_id, false), do: "▲", else: "▼") %>
                        </button>
                      </div>
                    </div>
                    <div
                      :if={Map.get(@expanded, job.external_id, false)}
                      class="mt-2 p-2 bg-base-300 rounded text-xs"
                    >
                      <p class="whitespace-pre-wrap"><%= job.description || "Sem descrição" %></p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    jobs =
      AutoVagas.Crawler.JobsStore.load()
      |> Enum.map(fn job ->
        job
        |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
        |> Map.put(:selected, false)
      end)

    search_form = to_form(%{"keywords" => "", "location" => "Brazil", "source" => "linkedin"})

    filter_form =
      to_form(%{
        "exclude_words" => "",
        "include_words" => "",
        "remote_only" => false,
        "require_keywords" => ""
      })

    # Carrega regras e buscas salvas
    user_info = AutoVagas.UserInfo.load()
    rules = Map.get(user_info, "rules", [])
    saved_searches = Map.get(user_info, "searches", [])

    {:ok,
     socket
     |> assign(:active_page, "vagas")
     |> assign(jobs: jobs, displayed_jobs: jobs, search_query: "", selected_ids: MapSet.new())
     |> assign(search_form: search_form, filter_form: filter_form)
     |> assign(expanded: %{}, show_filters: false)
     |> assign(loading: false, searched: false)
     |> assign(rules: rules, saved_searches: saved_searches)}
  end

  def handle_event("search", %{"keywords" => keywords}, socket) do
    if keywords == "" do
      {:noreply, socket}
    else
      socket = assign(socket, loading: true, searched: true)
      Process.send(self(), {:run_search, keywords}, [])
      {:noreply, socket}
    end
  end

  def handle_event("filter_jobs", %{"q" => query}, socket) do
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

    AutoVagas.Crawler.JobsStore.save(remaining)

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
    AutoVagas.Crawler.JobsStore.clear()
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
        "remote_only" => params["remote_only"] == "true",
        "require_keywords" => parse_list(params["require_keywords"])
      }
    }

    filtered = Filter.apply(socket.assigns.jobs, filters)

    {:noreply, socket |> assign(displayed_jobs: filtered)}
  end

  # Automation Rule Handlers
  def handle_event("new_rule", _params, socket) do
    rules = socket.assigns.rules

    new_rule = %{
      "id" => System.unique_integer([:positive]),
      "name" => "Nova Regra",
      "keywords" => [],
      "source" => "linkedin",
      "location" => "Brazil",
      "schedule" => "daily",
      "active" => true,
      "created_at" => DateTime.utc_now() |> DateTime.to_iso8601()
    }

    updated_rules = rules ++ [new_rule]

    # Salva no user_info
    user_info = AutoVagas.UserInfo.load()
    updated = Map.put(user_info, "rules", updated_rules)
    AutoVagas.UserInfo.save(updated)

    {:noreply, assign(socket, rules: updated_rules)}
  end

  def handle_event("toggle_rule", %{"value" => id}, socket) do
    rules = socket.assigns.rules

    updated_rules =
      Enum.map(rules, fn rule ->
        if Map.get(rule, "id") == id do
          Map.put(rule, "active", not Map.get(rule, "active", false))
        else
          rule
        end
      end)

    user_info = AutoVagas.UserInfo.load()
    updated = Map.put(user_info, "rules", updated_rules)
    AutoVagas.UserInfo.save(updated)

    {:noreply, assign(socket, rules: updated_rules)}
  end

  def handle_event("edit_rule", %{"value" => id}, socket) do
    # Por enquanto, apenas toggle active/inactive
    handle_event("toggle_rule", %{"value" => id}, socket)
  end

  def handle_event("delete_rule", %{"value" => id}, socket) do
    rules = socket.assigns.rules
    updated_rules = Enum.reject(rules, fn rule -> Map.get(rule, "id") == id end)

    user_info = AutoVagas.UserInfo.load()
    updated = Map.put(user_info, "rules", updated_rules)
    AutoVagas.UserInfo.save(updated)

    {:noreply, assign(socket, rules: updated_rules)}
  end

  def handle_event("run_search", %{"value" => search_id}, socket) do
    searches = socket.assigns.saved_searches

    case Enum.find(searches, fn s -> Map.get(s, "id") == search_id end) do
      nil ->
        {:noreply, put_flash(socket, :error, "Busca não encontrada")}

      search ->
        keywords = Map.get(search, "keywords", "")
        location = Map.get(search, "location", "Brazil")

        socket = assign(socket, loading: true, searched: true)
        Process.send(self(), {:run_search, keywords, location}, [])
        {:noreply, socket}
    end
  end

  def handle_info({:run_search, keywords, location}, socket) do
    # Executa busca usando nova lógica (RapidAPI → Guest API → Scraping)
    result = Engine.fetch_jobs("linkedin", keywords, location, nil, nil)

    case result do
      {:ok, jobs} ->
        # Converte para formato interno com átomos
        formatted_jobs =
          Enum.map(jobs, fn job ->
            %{
              title: Map.get(job, :title, ""),
              company: Map.get(job, :company, ""),
              location: Map.get(job, :location, "Remote"),
              url: Map.get(job, :url, ""),
              external_id: Map.get(job, :external_id, ""),
              source: "linkedin",
              selected: false
            }
          end)

        # Salva no Mnesia
        AutoVagas.Crawler.JobsStore.save(formatted_jobs)

        socket =
          socket
          |> assign(loading: false, displayed_jobs: formatted_jobs, jobs: formatted_jobs)

        {:noreply, socket}

      {:error, reason} ->
        socket = assign(socket, loading: false)
        {:noreply, put_flash(socket, :error, "Erro na busca: #{inspect(reason)}")}
    end
  end

  # Compatibilidade com código antigo
  def handle_info({:run_search, keywords}, socket) do
    handle_info({:run_search, keywords, "Brazil"}, socket)
  end

  defp parse_list(""), do: []

  defp parse_list(s) when is_binary(s),
    do: String.split(s, ",") |> Enum.map(&String.trim/1) |> Enum.reject(&(&1 == ""))

  defp parse_list(l), do: l
end
