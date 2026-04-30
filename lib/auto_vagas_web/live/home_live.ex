defmodule AutoVagasWeb.HomeLive do
  use AutoVagasWeb, :live_view

  alias AutoVagas.Crawler.JobsStore

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="max-w-6xl mx-auto p-6">
        <!-- Welcome Section -->
        <div class="mb-8">
          <h1 class="text-3xl font-bold text-base-content mb-2">Bem-vindo ao AutoVagas</h1>
          <p class="text-base-content/60">Gerencie suas buscas de emprego de forma automatizada</p>
        </div>

        <!-- Stats Cards -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
          <div class="stat bg-base-200 rounded-lg p-4">
            <div class="stat-figure text-primary">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
              </svg>
            </div>
            <div class="stat-title">Vagas Capturadas</div>
            <div class="stat-value text-primary"><%= @total_jobs %></div>
            <div class="stat-desc">Total acumulado</div>
          </div>

          <div class="stat bg-base-200 rounded-lg p-4">
            <div class="stat-figure text-secondary">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
            </div>
            <div class="stat-title">Buscas Realizadas</div>
            <div class="stat-value text-secondary"><%= @total_searches %></div>
            <div class="stat-desc">Nesta sessão</div>
          </div>

          <div class="stat bg-base-200 rounded-lg p-4">
            <div class="stat-figure text-accent">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <div class="stat-title">Integrações Ativas</div>
            <div class="stat-value text-accent"><%= @active_integrations %></div>
            <div class="stat-desc">LinkedIn, Indeed, Gupy</div>
          </div>
        </div>

        <!-- Quick Actions -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
          <div class="card bg-base-200 shadow-sm">
            <div class="card-body">
              <h2 class="card-title text-base-content">Buscar Vagas</h2>
              <p class="text-base-content/60 text-sm">Encontre novas oportunidades com filtros avançados</p>
              <div class="card-actions justify-end mt-4">
                 <.link navigate="/vagas" class="btn btn-primary">Iniciar Busca</.link>
              </div>
            </div>
          </div>

          <div class="card bg-base-200 shadow-sm">
            <div class="card-body">
              <h2 class="card-title text-base-content">Minhas Habilidades</h2>
              <p class="text-base-content/60 text-sm">Visualize seu perfil extraído por IA</p>
              <div class="card-actions justify-end mt-4">
                <.link navigate="/habilidades" class="btn btn-primary">Ver Habilidades</.link>
              </div>
            </div>
          </div>
        </div>

        <!-- Recent Jobs Preview -->
        <div class="bg-base-200 rounded-lg p-6">
          <div class="flex justify-between items-center mb-4">
            <h2 class="text-xl font-semibold text-base-content">Vagas Recentes</h2>
            <.link navigate="/vagas" class="btn btn-sm btn-ghost">Ver Todas</.link>
          </div>

          <div :if={@recent_jobs == []} class="text-center py-8 text-base-content/50">
            <p>Nenhuma vaga capturada ainda.</p>
                 <.link navigate="/vagas" class="btn btn-primary btn-sm mt-4">Fazer Primeira Busca</.link>
          </div>

          <div :if={@recent_jobs != []} class="space-y-3">
            <div :for={job <- @recent_jobs} class="flex items-center justify-between p-3 bg-base-100 rounded-lg">
              <div class="flex-1">
                <h3 class="font-medium text-base-content"><%= job.title %></h3>
                <p class="text-sm text-base-content/60"><%= job.company %> • <%= job.location %></p>
              </div>
              <span class="badge badge-sm"><%= job.source %></span>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    jobs = JobsStore.load()
    total_jobs = length(jobs)

    recent_jobs =
      jobs
      |> Enum.sort_by(fn j -> j["captured_at"] || "" end, {:desc, String})
      |> Enum.take(5)
      |> Enum.map(fn j ->
        %{
          title: j["title"] || "Sem título",
          company: j["company"] || "N/A",
          location: j["location"] || "Remoto",
          source: j["source"] || "unknown"
        }
      end)

    user_info = load_user_info()
    auth_status = Map.get(user_info, "auth_status", %{})
    active_integrations = count_active_integrations(auth_status)

    socket =
      socket
      |> assign(:active_page, "home")
      |> assign(:total_jobs, total_jobs)
      |> assign(:total_searches, 0)
      |> assign(:recent_jobs, recent_jobs)
      |> assign(:active_integrations, active_integrations)

    {:ok, socket}
  end

  defp count_active_integrations(auth_status) do
    ["linkedin", "indeed", "gupy"]
    |> Enum.count(fn source -> Map.get(auth_status, source, false) end)
  end

  defp load_user_info do
    try do
      "priv/user_info.json"
      |> File.read!()
      |> Jason.decode!()
    rescue
      _ -> %{}
    end
  end
end
