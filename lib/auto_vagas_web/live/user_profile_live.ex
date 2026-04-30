defmodule AutoVagasWeb.UserProfileLive do
  use AutoVagasWeb, :live_view

  alias AutoVagas.LinkedInProfile
  alias AutoVagas.Crawler.UserConfig

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="max-w-4xl mx-auto p-6">
        <div class="mb-6">
          <h1 class="text-3xl font-bold text-base-content">Meu Perfil</h1>
          <p class="text-base-content/60">Informações pessoais e preferências de busca</p>
        </div>

        <!-- Basic Info -->
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
                <p class="text-sm text-base-content/60">Sincronize dados automaticamente via scraping</p>
              </div>
              <button phx-click="sync_linkedin" class="btn btn-primary btn-sm" disabled={@syncing}>
                <span :if={@syncing} class="loading loading-spinner loading-xs mr-2"></span>
                <%= if @syncing, do: "Sincronizando...", else: "Sincronizar" %>
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
              <p class="text-xs mt-1">Clique em "Sincronizar" para extrair dados do LinkedIn</p>
            </div>
          </div>
        </div>

        <!-- Search Preferences (from Python crawler) -->
        <div class="card bg-base-200 shadow-sm mb-6">
          <div class="card-body">
            <h2 class="card-title text-base-content mb-4">Preferências de Busca</h2>
            <p class="text-sm text-base-content/60 mb-4">
              Configurações baseadas no LinkedIn Job Crawler Python
            </p>

            <.form for={@prefs_form} phx-submit="save_prefs" class="space-y-4">
              <!-- Experience Levels -->
              <div class="form-control">
                <label class="label">
                  <span class="label-text font-medium">Nível de Experiência</span>
                </label>
                <div class="grid grid-cols-2 md:grid-cols-3 gap-2">
                  <label class="label cursor-pointer justify-start gap-2">
                    <.input field={@prefs_form[:exp_internship]} type="checkbox" class="checkbox checkbox-sm" />
                    <span class="label-text text-sm">Estágio</span>
                  </label>
                  <label class="label cursor-pointer justify-start gap-2">
                    <.input field={@prefs_form[:exp_entry]} type="checkbox" class="checkbox checkbox-sm" />
                    <span class="label-text text-sm">Entry Level</span>
                  </label>
                  <label class="label cursor-pointer justify-start gap-2">
                    <.input field={@prefs_form[:exp_associate]} type="checkbox" class="checkbox checkbox-sm" />
                    <span class="label-text text-sm">Associate</span>
                  </label>
                  <label class="label cursor-pointer justify-start gap-2">
                    <.input field={@prefs_form[:exp_mid_senior]} type="checkbox" class="checkbox checkbox-sm" />
                    <span class="label-text text-sm">Mid-Senior</span>
                  </label>
                  <label class="label cursor-pointer justify-start gap-2">
                    <.input field={@prefs_form[:exp_director]} type="checkbox" class="checkbox checkbox-sm" />
                    <span class="label-text text-sm">Director</span>
                  </label>
                  <label class="label cursor-pointer justify-start gap-2">
                    <.input field={@prefs_form[:exp_executive]} type="checkbox" class="checkbox checkbox-sm" />
                    <span class="label-text text-sm">Executive</span>
                  </label>
                </div>
              </div>

              <!-- Job Types -->
              <div class="form-control">
                <label class="label">
                  <span class="label-text font-medium">Tipo de Vaga</span>
                </label>
                <div class="grid grid-cols-2 md:grid-cols-3 gap-2">
                  <label class="label cursor-pointer justify-start gap-2">
                    <.input field={@prefs_form[:job_full_time]} type="checkbox" class="checkbox checkbox-sm" />
                    <span class="label-text text-sm">Full-time</span>
                  </label>
                  <label class="label cursor-pointer justify-start gap-2">
                    <.input field={@prefs_form[:job_contract]} type="checkbox" class="checkbox checkbox-sm" />
                    <span class="label-text text-sm">Contract</span>
                  </label>
                  <label class="label cursor-pointer justify-start gap-2">
                    <.input field={@prefs_form[:job_part_time]} type="checkbox" class="checkbox checkbox-sm" />
                    <span class="label-text text-sm">Part-time</span>
                  </label>
                  <label class="label cursor-pointer justify-start gap-2">
                    <.input field={@prefs_form[:job_temporary]} type="checkbox" class="checkbox checkbox-sm" />
                    <span class="label-text text-sm">Temporary</span>
                  </label>
                  <label class="label cursor-pointer justify-start gap-2">
                    <.input field={@prefs_form[:job_internship]} type="checkbox" class="checkbox checkbox-sm" />
                    <span class="label-text text-sm">Internship</span>
                  </label>
                  <label class="label cursor-pointer justify-start gap-2">
                    <.input field={@prefs_form[:job_other]} type="checkbox" class="checkbox checkbox-sm" />
                    <span class="label-text text-sm">Other</span>
                  </label>
                  <label class="label cursor-pointer justify-start gap-2">
                    <.input field={@prefs_form[:job_volunteer]} type="checkbox" class="checkbox checkbox-sm" />
                    <span class="label-text text-sm">Volunteer</span>
                  </label>
                </div>
              </div>

              <!-- Date Filter -->
              <div class="form-control">
                <label class="label">
                  <span class="label-text font-medium">Período de Publicação</span>
                </label>
                <.input
                  field={@prefs_form[:date_range]}
                  type="select"
                  options={[
                    {"Qualquer data", "all"},
                    {"Último mês", "r2592000"},
                    {"Última semana", "r604800"},
                    {"Últimas 24 horas", "r86400"}
                  ]}
                  class="select select-bordered w-full"
                />
              </div>

              <!-- Blacklists -->
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div class="form-control">
                  <label class="label">
                    <span class="label-text font-medium">Lista Negra: Empresas</span>
                  </label>
                  <.input
                    field={@prefs_form[:company_blacklist]}
                    type="text"
                    placeholder="empresa1, empresa2..."
                    class="input input-bordered w-full"
                  />
                  <label class="label">
                    <span class="label-text-alt">Separadas por vírgula</span>
                  </label>
                </div>

                <div class="form-control">
                  <label class="label">
                    <span class="label-text font-medium">Lista Negra: Títulos</span>
                  </label>
                  <.input
                    field={@prefs_form[:title_blacklist]}
                    type="text"
                    placeholder="palavra1, palavra2..."
                    class="input input-bordered w-full"
                  />
                  <label class="label">
                    <span class="label-text-alt">Palavras que devem ser excluídas</span>
                  </label>
                </div>
              </div>

              <div class="card-actions justify-end">
                <button type="submit" class="btn btn-primary">Salvar Preferências</button>
              </div>
            </.form>
          </div>
        </div>

        <!-- Navigation -->
        <div class="flex gap-2">
          <.link navigate="/configuracoes" class="btn btn-ghost btn-sm">
            ← Integrações
          </.link>
          <.link navigate="/vagas" class="btn btn-primary btn-sm">
            Buscar Vagas
          </.link>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    user_info = UserConfig.load()

    linkedin_url = Map.get(user_info, "linkedin_profile_url", "")
    linkedin_data = Map.get(user_info, "linkedin_profile", %{})

    basic_form =
      to_form(%{
        "name" => Map.get(user_info, "name", ""),
        "location" => Map.get(user_info, "location", ""),
        "linkedin_url" => linkedin_url
      })

    filters = Map.get(user_info, "filters", %{})
    global = Map.get(filters, "global", %{})

    prefs_form =
      to_form(%{
        "exp_internship" => Map.get(global, "exp_internship", false),
        "exp_entry" => Map.get(global, "exp_entry", true),
        "exp_associate" => Map.get(global, "exp_associate", false),
        "exp_mid_senior" => Map.get(global, "exp_mid_senior", false),
        "exp_director" => Map.get(global, "exp_director", false),
        "exp_executive" => Map.get(global, "exp_executive", false),
        "job_full_time" => Map.get(global, "job_full_time", true),
        "job_contract" => Map.get(global, "job_contract", false),
        "job_part_time" => Map.get(global, "job_part_time", false),
        "job_temporary" => Map.get(global, "job_temporary", false),
        "job_internship" => Map.get(global, "job_internship", false),
        "job_other" => Map.get(global, "job_other", false),
        "job_volunteer" => Map.get(global, "job_volunteer", false),
        "date_range" => Map.get(global, "date_range", "all"),
        "company_blacklist" => Map.get(global, "company_blacklist", []) |> Enum.join(", "),
        "title_blacklist" => Map.get(global, "title_blacklist", []) |> Enum.join(", ")
      })

    {:ok,
     socket
     |> assign(:active_page, "perfil")
     |> assign(basic_form: basic_form, prefs_form: prefs_form)
     |> assign(linkedin_data: linkedin_data, syncing: false)}
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

  def handle_event("save_prefs", %{"user_profile" => params}, socket) do
    user_info = UserConfig.load()
    filters = Map.get(user_info, "filters", %{})

    updated_global =
      %{}
      |> Map.put("exp_internship", params["exp_internship"] == "true")
      |> Map.put("exp_entry", params["exp_entry"] == "true")
      |> Map.put("exp_associate", params["exp_associate"] == "true")
      |> Map.put("exp_mid_senior", params["exp_mid_senior"] == "true")
      |> Map.put("exp_director", params["exp_director"] == "true")
      |> Map.put("exp_executive", params["exp_executive"] == "true")
      |> Map.put("job_full_time", params["job_full_time"] == "true")
      |> Map.put("job_contract", params["job_contract"] == "true")
      |> Map.put("job_part_time", params["job_part_time"] == "true")
      |> Map.put("job_temporary", params["job_temporary"] == "true")
      |> Map.put("job_internship", params["job_internship"] == "true")
      |> Map.put("job_other", params["job_other"] == "true")
      |> Map.put("job_volunteer", params["job_volunteer"] == "true")
      |> Map.put("date_range", params["date_range"])
      |> Map.put("company_blacklist", parse_list(params["company_blacklist"]))
      |> Map.put("title_blacklist", parse_list(params["title_blacklist"]))

    updated_filters = Map.put(filters, "global", updated_global)
    updated = Map.put(user_info, "filters", updated_filters)

    UserConfig.save(updated)

    {:noreply, put_flash(socket, :info, "Preferências salvas!")}
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

  defp parse_list(""), do: []

  defp parse_list(s) when is_binary(s),
    do: s |> String.split(",") |> Enum.map(&String.trim/1) |> Enum.reject(&(&1 == ""))

  defp parse_list(l), do: l
end
