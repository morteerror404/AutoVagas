defmodule AutoVagasWeb.JobsLive do
  use AutoVagasWeb, :live_view

  alias AutoVagas.Crawler.Filter

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="max-w-6xl mx-auto p-6">
        <!-- Header -->
        <div class="flex flex-col md:flex-row justify-between items-start md:items-center mb-6 gap-4">
          <div>
            <h1 class="text-3xl font-bold text-base-content">Vagas Capturadas</h1>
            <p class="text-base-content/60"><%= length(@displayed_jobs) %> de <%= length(@jobs) %> vagas</p>
          </div>
          <div class="flex gap-2">
            <.link navigate="/buscar" class="btn btn-primary btn-sm">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
              Nova Busca
            </.link>
            <button phx-click="clear_all" class="btn btn-error btn-sm">
              Limpar Tudo
            </button>
          </div>
        </div>

        <!-- Toolbar -->
        <div class="bg-base-200 rounded-lg p-4 mb-6">
          <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <!-- Search -->
            <div class="form-control">
              <.form for={@search_form} phx-change="search" class="w-full">
                <div class="input-group">
                  <input
                    type="text"
                    name="q"
                    placeholder="Buscar por título, empresa..."
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

            <!-- Bulk Actions -->
            <div class="flex gap-2">
              <button phx-click="select_all" class="btn btn-sm btn-outline flex-1">
                Selecionar Todas
              </button>
              <button phx-click="deselect_all" class="btn btn-sm btn-outline flex-1">
                Desmarcar
              </button>
            </div>

            <!-- Toggle Filters -->
            <div class="flex justify-end">
              <button phx-click="toggle_filters" class={"btn btn-sm " <> if(@show_filters, do: "btn-active", else: "btn-ghost")}>
                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z" />
                </svg>
                Filtros
              </button>
            </div>
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
              <div class="form-control">
                <label class="label cursor-pointer justify-start gap-2">
                  <input type="checkbox" name="remote_only" class="checkbox checkbox-sm" />
                  <span class="label-text text-xs">Apenas Remoto</span>
                </label>
              </div>
              <div class="form-control">
                <input
                  type="text"
                  name="require_keywords"
                  placeholder="exigir estas palavras"
                  class="input input-bordered input-sm w-full"
                />
              </div>
            </.form>
          </div>
        </div>

        <!-- Delete Selected -->
        <.form for={%{}} phx-change="delete_selected" class="mb-4">
          <button
            type="submit"
            phx-click="delete_selected"
            class={"btn btn-sm btn-error " <> if(MapSet.size(@selected_ids) == 0, do: "btn-disabled", else: "")}
            disabled={MapSet.size(@selected_ids) == 0}
          >
            Excluir <%= MapSet.size(@selected_ids) %> Selecionadas
          </button>
        </.form>

        <!-- Jobs List -->
        <div :if={@displayed_jobs == []} class="text-center py-16">
          <div class="text-6xl mb-4">📭</div>
          <p class="text-base-content/50 text-lg">Nenhuma vaga capturada.</p>
          <.link navigate="/buscar" class="btn btn-primary mt-4">Fazer Busca</.link>
        </div>

        <div :if={@displayed_jobs != []} class="space-y-3">
          <div :for={job <- @displayed_jobs} class="card bg-base-200 shadow-sm hover:shadow-md transition-shadow">
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
                    <div class="badge badge-primary badge-sm"><%= job.source %></div>
                  </div>

                  <div class="flex gap-2 mt-3">
                    <a href={job.url} target="_blank" class="btn btn-primary btn-xs">
                      Ver Original
                    </a>
                    <button phx-click="toggle_details" phx-value={job.external_id} class="btn btn-ghost btn-xs">
                      <%= if(Map.get(@expanded, job.external_id, false), do: "Ocultar", else: "Detalhes") %>
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

    search_form = to_form(%{"q" => ""})

    filter_form =
      to_form(%{
        "exclude_words" => "",
        "include_words" => "",
        "remote_only" => false,
        "require_keywords" => ""
      })

    {:ok,
     socket
     |> assign(:active_page, "vagas")
     |> assign(jobs: jobs, displayed_jobs: jobs, search_query: "", selected_ids: MapSet.new())
     |> assign(search_form: search_form, filter_form: filter_form)
     |> assign(expanded: %{}, show_filters: false)}
  end

  def handle_event("search", %{"q" => query}, socket) do
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

  defp parse_list(""), do: []

  defp parse_list(s) when is_binary(s),
    do: String.split(s, ",") |> Enum.map(&String.trim/1) |> Enum.reject(&(&1 == ""))

  defp parse_list(l), do: l
end
