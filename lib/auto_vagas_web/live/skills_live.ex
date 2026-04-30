defmodule AutoVagasWeb.SkillsLive do
  use AutoVagasWeb, :live_view

  alias AutoVagas.LinkedInProfile
  alias AutoVagas.Crawler.UserConfig

  @doc """
  Pagina de habilidades com criacao de perfil integrada.
  """
  def mount(_params, _session, socket) do
    user_info = load_user_info()
    skills = Map.get(user_info, "skills", %{})

    # Carrega dados do perfil LinkedIn
    linkedin_url = Map.get(user_info, "linkedin_profile_url", "")
    linkedin_data = Map.get(user_info, "linkedin_profile", %{})

    # Formularios
    basic_form = to_form(%{
      "name" => Map.get(user_info, "name", ""),
      "location" => Map.get(user_info, "location", ""),
      "linkedin_url" => linkedin_url
    })

    {:ok,
     socket
     |> assign(:active_page, "habilidades")
     |> assign(:user_info, user_info)
     |> assign(:skills, skills)
     |> assign(:active_tab, "technical")
     |> assign(:expanded, %{})
     |> assign(:basic_form, basic_form)
     |> assign(:linkedin_data, linkedin_data)
     |> assign(:syncing, false)}
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

    case AutoVagas.LLM.Explanation.update_skills_with_explanations(user_info) do
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

  def handle_event("toggle_explanation", %{"value" => item_name}, socket) do
    expanded = Map.get(socket.assigns, :expanded, %{})
    updated = Map.put(expanded, item_name, not Map.get(expanded, item_name, false))
    {:noreply, assign(socket, :expanded, updated)}
  end

  def handle_event("save_basic", %{"user_profile" => params}, socket) do
    user_info = UserConfig.load()

    updated =
      user_info
      |> Map.put("name", params["name"])
      |> Map.put("location", params["location"])
      |> Map.put("linkedin_profile_url", params["linkedin_url"])

    UserConfig.save(updated)

    if params["linkedin_url"] != "" do
      LinkedInProfile.set_profile_url(updated, params["linkedin_url"])
    end

    {:noreply, put_flash(socket, :info, "Perfil salvo!")}
  end

  def handle_event("sync_linkedin", _params, socket) do
    socket = assign(socket, syncing: true)

    user_info = UserConfig.load()

    case LinkedInProfile.fetch_and_update(user_info, use_scraping: true) do
      {:ok, updated} ->
        {:noreply,
         socket
         |> assign(syncing: false, linkedin_data: Map.get(updated, "linkedin_profile", %{}))
         |> put_flash(:info, "Perfil sincronizado com sucesso!")}

      {:error, reason} ->
        {:noreply,
         socket
         |> assign(syncing: false)
         |> put_flash(:error, "Erro ao sincronizar: #{inspect(reason)}")}
    end
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
            <h1 class="text-3xl font-bold text-base-content">Meu Perfil e Habilidades</h1>
            <p class="text-base-content/60">Configurar perfil e visualizar competências</p>
          </div>
          <button phx-click="update_skills" class="btn btn-primary">
            Atualizar c/ IA
          </button>
        </div>

        <!-- Basic Info Card -->
        <div class="card bg-base-200 shadow-sm mb-6">
          <div class="card-body">
            <h2 class="card-title text-base-content mb-4">Informações Básicas</h2>
            <.form for={@basic_form} phx-submit="save_basic" class="space-y-4">
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div class="form-control">
                  <label class="label">
                    <span class="label-text font-medium">Nome</span>
                  </label>
                  <.input field={@basic_form[:name]} type="text" class="input input-bordered w-full" />
                </div>
                <div class="form-control">
                  <label class="label">
                    <span class="label-text font-medium">Localização</span>
                  </label>
                  <.input field={@basic_form[:location]} type="text" class="input input-bordered w-full" />
                </div>
              </div>

              <div class="form-control">
                <label class="label">
                  <span class="label-text font-medium">URL do Perfil LinkedIn</span>
                </label>
                <.input field={@basic_form[:linkedin_url]} type="text" class="input input-bordered w-full"
                  placeholder="https://www.linkedin.com/in/seu-perfil" />
              </div>

              <div class="card-actions justify-end">
                <button type="submit" class="btn btn-primary">Salvar</button>
              </div>
            </.form>
          </div>
        </div>

        <!-- LinkedIn Sync -->
        <div class="card bg-base-200 shadow-sm mb-6">
          <div class="card-body">
            <div class="flex items-center justify-between mb-4">
              <div>
                <h2 class="card-title text-base-content">Perfil LinkedIn</h2>
                <p class="text-sm text-base-content/60">Sincronize dados automaticamente via LinkedIn</p>
              </div>
              <button phx-click="sync_linkedin" class="btn btn-primary btn-sm" disabled={@syncing}>
                <span :if={@syncing} class="loading loading-spinner loading-xs mr-2"></span>
                <%= if @syncing, do: "Sincronizando...", else: "Conectar LinkedIn" %>
              </button>
            </div>

            <div :if={@linkedin_data != %{}} class="bg-base-100 p-4 rounded-lg">
              <h3 class="font-bold mb-2"><%= Map.get(@linkedin_data, "name", "") %></h3>
              <p class="text-sm text-base-content/70"><%= Map.get(@linkedin_data, "headline", "") %></p>
              <p class="text-xs text-base-content/50 mt-1"><%= Map.get(@linkedin_data, "location", "") %></p>

              <div :if={Map.get(@linkedin_data, "skills", []) != []} class="mt-4">
                <h4 class="font-bold text-sm mb-2">Habilidades Extraídas:</h4>
                <div class="flex flex-wrap gap-2">
                  <span :for={skill <- Map.get(@linkedin_data, "skills", [])} class="badge badge-primary">
                    <%= skill %>
                  </span>
                </div>
              </div>
            </div>

            <div :if={@linkedin_data == %{}} class="text-center py-4 text-base-content/50">
              <p class="text-sm">Nenhum dado sincronizado ainda.</p>
              <p class="text-xs mt-1">Clique em "Conectar LinkedIn" para extrair dados</p>
            </div>
          </div>
        </div>

        <!-- Skills Tabs -->
        <div class="bg-base-200 rounded-lg p-6">
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
            <button phx-click="update_skills" class="btn btn-primary btn-sm mt-4">Atualizar c/ IA</button>
          </div>
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
