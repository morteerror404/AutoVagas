defmodule AutoVagasWeb.SkillsLive do
  use AutoVagasWeb, :live_view

  @doc """
  Monta a página de habilidades.
  """
  def mount(_params, _session, socket) do
    user_info = load_user_info()
    skills = Map.get(user_info, "skills", %{})
    
    {:ok, 
     socket
     |> assign(:active_page, "habilidades")
     |> assign(:user_info, user_info)
     |> assign(:skills, skills)
     |> assign(:active_tab, "technical")
     |> assign(:expanded, %{})}
  end

  defp load_user_info do
    "priv/user_info.json"
    |> File.read!()
    |> Jason.decode!()
  end

  def handle_event("switch_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :active_tab, tab)}
  end

  def handle_event("update_skills", _params, socket) do
    user_info = socket.assigns.user_info
    
    case AutoVagas.AI.Explanation.update_skills_with_explanations(user_info) do
      {:ok, updated} ->
        save_user_info(updated)
        {:noreply, 
         socket
         |> put_flash(:info, "Habilidades atualizadas com sucesso!")
         |> assign(:user_info, updated)
         |> assign(:skills, Map.get(updated, "skills", %{}))}
      
      error ->
        {:noreply, put_flash(socket, :error, "Erro: #{inspect(error)}")}
    end
  end

  def handle_event("toggle_explanation", %{"item" => item_name}, socket) do
    expanded = Map.get(socket.assigns, :expanded, %{})
    updated = Map.put(expanded, item_name, not Map.get(expanded, item_name, false))
    {:noreply, assign(socket, :expanded, updated)}
  end

  defp save_user_info(data) do
    File.write!("priv/user_info.json", Jason.encode!(data, pretty: true))
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="max-w-6xl mx-auto p-6">
        <div class="flex justify-between items-center mb-6">
          <div>
            <h1 class="text-3xl font-bold text-base-content">Minhas Habilidades</h1>
            <p class="text-base-content/60">Visualização completa de competências</p>
          </div>
          <button phx-click="update_skills" class="btn btn-primary">
            Atualizar c/ IA
          </button>
        </div>

        <!-- Tabs -->
        <div class="tabs tabs-boxed mb-6">
          <a class={"tab " <> if(@active_tab == "technical", do: "tab-active", else: "")} 
             phx-click="switch_tab" phx-value="technical">
            Técnicas
          </a>
          <a class={"tab " <> if(@active_tab == "soft", do: "tab-active", else: "")} 
             phx-click="switch_tab" phx-value="soft">
            Comportamentais
          </a>
          <a class={"tab " <> if(@active_tab == "certifications", do: "tab-active", else: "")} 
             phx-click="switch_tab" phx-value="certifications">
            Certificações
          </a>
          <a class={"tab " <> if(@active_tab == "courses", do: "tab-active", else: "")} 
             phx-click="switch_tab" phx-value="courses">
            Cursos
          </a>
          <a class={"tab " <> if(@active_tab == "hack_the_box", do: "tab-active", else: "")} 
             phx-click="switch_tab" phx-value="hack_the_box">
            Hack The Box
          </a>
        </div>

        <!-- Skills Display -->
        <div :if={@active_tab == "technical"}>
          <.skills_section skills={Map.get(@skills, "technical", [])} expanded={assigns.expanded} />
        </div>

        <div :if={@active_tab == "soft"}>
          <.skills_section skills={Map.get(@skills, "soft", [])} expanded={assigns.expanded} />
        </div>

        <div :if={@active_tab == "certifications"}>
          <.skills_section skills={Map.get(@skills, "certifications", [])} expanded={assigns.expanded} />
        </div>

        <div :if={@active_tab == "courses"}>
          <.skills_section skills={Map.get(@skills, "courses", [])} expanded={assigns.expanded} />
        </div>

        <div :if={@active_tab == "hack_the_box"}>
          <.skills_section skills={Map.get(@skills, "hack_the_box", [])} expanded={assigns.expanded} />
        </div>

        <div :if={Map.get(@skills, "technical", []) == [] && Map.get(@skills, "soft", []) == []} 
             class="text-center py-8 text-base-content/50">
          <p>Nenhuma habilidade cadastrada.</p>
          <.link navigate="/configuracoes" class="btn btn-primary mt-4">Configurar Perfil</.link>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp skills_section(assigns) do
    ~H"""
    <div class="space-y-4">
      <h2 class="text-xl font-bold">{assigns[:skills] |> length() |> to_string()} Habilidades</h2>
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <div :for={skill <- assigns[:skills]} class="card bg-base-200 shadow-sm">
          <div class="card-body p-4">
            <div class="flex justify-between items-start">
              <div>
                <h3 class="font-bold">{skill["name"]}</h3>
                <p class="text-sm text-base-content/70">{skill["level"] || "Intermediate"}</p>
              </div>
              <span class="badge badge-primary">{skill["years"] || 0} anos</span>
            </div>
            <p :if={skill["explanation"]} class="text-sm mt-2 text-base-content/60">
              {skill["explanation"]}
            </p>
            <button phx-click="toggle_explanation" 
                    phx-value={skill["name"]}
                    class="btn btn-xs btn-ghost mt-2">
              {if Map.get(assigns[:expanded] || %{}, skill["name"], false), do: "Ocultar", else: "Ver Explicação"}
            </button>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
