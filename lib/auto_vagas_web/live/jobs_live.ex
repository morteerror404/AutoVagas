defmodule AutoVagasWeb.JobsLive do
  use AutoVagasWeb, :live_view

  alias AutoVagas.Crawler.Filter

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="max-w-6xl mx-auto p-6">
        <div class="flex justify-between items-center mb-6">
          <div>
            <h1 class="text-3xl font-bold text-base-content">Vagas Capturadas</h1>
            <p class="text-base-content/60">{length(@jobs)} vagas</p>
          </div>
          <div class="flex gap-2">
            <button phx-click="clear_all" class="btn btn-error btn-sm">Limpar Tudo</button>
            <.link navigate="/buscar" class="btn btn-primary">Nova Busca</.link>
          </div>
        </div>

        <.form for={@search_form} phx-change="search" class="mb-4">
          <input
            type="text"
            name="q"
            placeholder="Buscar por título, empresa..."
            value={@search_query}
            class="input input-bordered w-full"
          />
        </.form>

        <div class="flex gap-2 mb-4">
          <button phx-click="select_all" class="btn btn-sm">Selecionar Todas</button>
          <button phx-click="deselect_all" class="btn btn-sm">Desmarcar Todas</button>
          <button phx-click="delete_selected" class="btn btn-error btn-sm">
            Excluir Selecionadas
          </button>
          <button phx-click="toggle_filters" class="btn btn-secondary btn-sm">
            {if @show_filters, do: "Ocultar Filtros", else: "Filtros"}
          </button>
        </div>

        <div :if={@show_filters} class="bg-base-200 rounded-lg p-4 mb-4 space-y-4">
          <h3 class="font-bold">Filtros Globais</h3>
          <.form for={@filter_form} phx-change="apply_filter" class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm mb-1">Palavras para EXCLUIR</label>
              <input
                type="text"
                name="exclude_words"
                placeholder="separadas por vírgula"
                class="input input-bordered w-full"
              />
            </div>
            <div>
              <label class="block text-sm mb-1">Palavras para INCLUIR (obriga)</label>
              <input
                type="text"
                name="include_words"
                placeholder="separadas por vírgula"
                class="input input-bordered w-full"
              />
            </div>
            <div>
              <label class="block text-sm mb-1">Apenas Remoto</label>
              <input type="checkbox" name="remote_only" class="checkbox" />
            </div>
            <div>
              <label class="block text-sm mb-1">Exigir palavras</label>
              <input
                type="text"
                name="require_keywords"
                placeholder="todas devem conter"
                class="input input-bordered w-full"
              />
            </div>
          </.form>
        </div>

        <div class="space-y-2">
          <div :for={job <- @displayed_jobs} class="card bg-base-200 shadow-sm">
            <div class="card-body p-4">
              <div class="flex items-start gap-3">
                <input
                  type="checkbox"
                  checked={job.selected}
                  phx-click="toggle_select"
                  phx-value={job.external_id}
                  class="checkbox"
                />
                <div class="flex-1">
                  <div class="flex justify-between">
                    <h3 class="font-bold text-base-content">{job.title}</h3>
                    <span class="badge badge-sm">{job.source}</span>
                  </div>
                  <p class="text-sm text-base-content/70">{job.company}</p>
                  <p class="text-xs text-base-content/50">{job.location}</p>
                  <div class="flex gap-2 mt-2">
                    <a href={job.url} target="_blank" class="btn btn-xs btn-primary">Ver Original</a>
                    <button phx-click="toggle_details" phx-value={job.external_id} class="btn btn-xs">
                      {if @expanded[job.external_id], do: "Ocultar", else: "Mostrar Detalhes"}
                    </button>
                  </div>
                  <div :if={@expanded[job.external_id]} class="mt-3 p-3 bg-base-300 rounded text-sm">
                    <p class="whitespace-pre-wrap">{job.description || "Descrição não disponível"}</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div :if={@displayed_jobs == []} class="text-center py-8 text-base-content/50">
          <p>Nenhuma vaga capturada.</p>
          <.link navigate="/buscar" class="btn btn-primary mt-4">Fazer busca</.link>
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
    ids = MapSet.new(Enum.map(socket.assigns.jobs, & &1["external_id"]))
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
