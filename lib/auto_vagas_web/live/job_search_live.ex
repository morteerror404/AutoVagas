defmodule AutoVagasWeb.JobSearchLive do
  use AutoVagasWeb, :live_view

  alias AutoVagas.Crawler.JobsStore

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="max-w-6xl mx-auto p-6">
        <h1 class="text-3xl font-bold text-base-content">Buscar Vagas</h1>
        <p class="text-base-content/60 mb-6">Encontre oportunidades</p>

        <.form for={@form} id="search-form" phx-submit="search" class="space-y-4">
          <div class="form-control">
            <label class="label">
              <span class="label-text">Palavras-chave *</span>
            </label>
            <.input field={@form[:keywords]} type="text" placeholder="ex: elixir..." class="w-full input-bordered" />
          </div>

          <div class="grid grid-cols-2 gap-4">
            <div class="form-control">
              <label class="label">
                <span class="label-text">Localização</span>
              </label>
              <.input field={@form[:location]} type="text" placeholder="Brazil" class="w-full input-bordered" />
            </div>
            <div class="form-control">
              <label class="label">
                <span class="label-text">Fonte</span>
              </label>
              <.input field={@form[:source]} type="select"
                options={[{"Todas", "all"}, {"LinkedIn", "linkedin"}]}
                class="w-full select-bordered" />
            </div>
          </div>

          <button type="submit" class="btn btn-primary w-full" disabled={@loading}>
            <span :if={@loading} class="loading loading-sm mr-2"></span>
            {if @loading, do: "Buscando...", else: "Buscar"}
          </button>
        </.form>

        <div :if={@displayed_jobs != []} class="mt-8 space-y-3">
          <h2 class="text-xl font-semibold">{length(@displayed_jobs)} vagas encontradas</h2>
          <div :for={job <- @displayed_jobs} class="card bg-base-200 p-4">
            <h3 class="font-bold"><%= job.title %></h3>
            <p class="text-sm text-base-content/70"><%= job.company %></p>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    form = to_form(%{"keywords" => "", "location" => "Brazil", "source" => "linkedin"})
    jobs = JobsStore.load()

    socket = socket
              |> assign(:active_page, "buscar")
              |> assign(form: form, jobs: jobs, displayed_jobs: jobs, loading: false, searched: false)

    {:ok, socket}
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

  def handle_info({:run_search, _keywords}, socket) do
    # Simplified search - just return some dummy results for now
    jobs = socket.assigns.jobs
    socket = assign(socket, loading: false, displayed_jobs: jobs)
    {:noreply, socket}
  end
end
