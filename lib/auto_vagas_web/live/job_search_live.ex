defmodule AutoVagasWeb.JobSearchLive do
  use AutoVagasWeb, :live_view

  alias AutoVagas.Crawler.JobsStore

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="max-w-6xl mx-auto p-6">
        <h1 class="text-3xl font-bold text-base-content mb-2">Buscar Vagas</h1>
        <p class="text-base-content/60 mb-8">Pesquise vagas em multiplas plataformas</p>

        <!-- Importar regra -->
        <div class="mb-6 bg-base-200 border border-base-300 rounded-lg p-4">
          <h3 class="font-semibold mb-3">Importar Regra</h3>
          <div class="flex gap-2">
            <.form for={@import_form} phx-submit="import_rule" class="flex gap-2 flex-1">
              <.input field={@import_form[:rule_path]} type="text"
                placeholder="Caminho do arquivo ou nome da regra" class="flex-1 input-bordered" />
              <button type="submit" class="btn btn-primary btn-sm">Importar</button>
            </.form>
            <button phx-click="show_rules_modal" class="btn btn-ghost btn-sm">Ver Regras</button>
          </div>
          <p class="text-xs text-base-content/60 mt-2">
            Digite o caminho completo ou apenas o nome da regra (busca em priv/rules/)
          </p>
        </div>

        <.form for={@form} id="search-form" phx-submit="search" class="space-y-4">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div class="form-control">
              <label class="label">
                <span class="label-text">Palavras-chave *</span>
              </label>
              <.input field={@form[:keywords]} type="text" placeholder="ex: elixir, phoenix..." class="w-full input-bordered" />
            </div>

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
                options={[{"Todas", "all"}, {"LinkedIn", "linkedin"}, {"Indeed", "indeed"}, {"Gupy", "gupy"}]}
                class="w-full select-bordered" />
            </div>
          </div>

          <button type="submit" class="btn btn-primary w-full" disabled={@loading}>
            <span :if={@loading} class="loading loading-sm mr-2"></span>
            {if @loading, do: "Pesquisando...", else: "Pesquisar Vagas"}
          </button>
        </.form>

        <div :if={@loading} class="text-center py-8">
          <span class="loading loading-lg"></span>
          <p class="mt-2">Pesquisando vagas...</p>
        </div>

        <div :if={@searched and not @loading} class="mt-8">
          <h2 class="text-xl font-semibold mb-4">{length(@jobs)} vagas encontradas</h2>

          <div class="grid gap-4">
            <div :for={job <- @jobs} id={"job-#{job["external_id"]}"} class="card bg-base-100 shadow border border-base-300">
              <div class="card-body">
                <h3 class="card-title text-lg">
                  <a href={job["url"]} target="_blank" class="link link-hover">{job["title"]}</a>
                </h3>
                <p class="text-sm text-base-content/70">{job["company"]}</p>
                <div class="flex gap-2 mt-2">
                  <span class="badge badge-outline">{job["location"]}</span>
                  <span :if={job["work_type"]} class="badge badge-outline">{job["work_type"]}</span>
                  <span class="badge badge-outline">{job["source"]}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Modal de regras disponíveis -->
      <div class={"modal " <> if(@show_rules_modal, do: "modal-open", else: "")}>
        <div class="modal-box">
          <h3 class="font-bold text-lg mb-4">Regras Disponíveis</h3>
          <div class="space-y-2 max-h-96 overflow-y-auto">
            <div :for={rule <- @available_rules} class="p-3 bg-base-100 rounded border border-base-300">
              <div class="flex justify-between items-center">
                <div>
                  <h4 class="font-semibold"><%= rule["name"] %></h4>
                  <p class="text-sm text-base-content/70"><%= Enum.join(rule["keywords"] || [], ", ") %></p>
                </div>
                <button phx-click="select_rule" phx-value={rule["id"]} class="btn btn-sm btn-primary">Usar</button>
              </div>
            </div>
            <div :if={@available_rules == []} class="text-center py-4 text-base-content/50">
              Nenhuma regra encontrada
            </div>
          </div>
          <div class="modal-action">
            <button phx-click="hide_rules_modal" class="btn btn-ghost">Fechar</button>
          </div>
        </div>
        <form phx-click="hide_rules_modal" class="modal-backdrop"></form>
      </div>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    form = to_form(%{
      "keywords" => "",
      "location" => "Brazil",
      "source" => "all"
    })

    import_form = to_form(%{"rule_path" => ""})

    jobs = JobsStore.load()

    {:ok, socket
     |> assign(form: form, import_form: import_form, jobs: jobs, loading: false, searched: false)
     |> assign(show_rules_modal: false, available_rules: [], selected_rule: nil)}
  end

  def handle_event("search", %{"keywords" => keywords} = params, socket) do
    if keywords == "" do
      {:noreply, socket}
    else
      socket = assign(socket, loading: true, searched: true, jobs: [])
      Process.send(self(), {:run_search, params, socket.assigns.selected_rule}, [])
      {:noreply, socket}
    end
  end

  def handle_event("import_rule", %{"rule_path" => rule_path}, socket) do
    rule = load_rule(rule_path)

    if rule do
      form = to_form(%{
        "keywords" => Enum.join(Map.get(rule, "keywords", []), ", "),
        "location" => Map.get(rule, "location", "Brazil"),
        "source" => Map.get(rule, "source", "all")
      })

      {:noreply,
       assign(socket, form: form, selected_rule: rule)
       |> put_flash(:info, "Regra '#{rule["name"]}' importada com sucesso!")}
    else
      {:noreply, put_flash(socket, :error, "Regra nao encontrada")}
    end
  end

  def handle_event("show_rules_modal", _, socket) do
    rules = load_all_rules()
    {:noreply, assign(socket, show_rules_modal: true, available_rules: rules)}
  end

  def handle_event("hide_rules_modal", _, socket) do
    {:noreply, assign(socket, show_rules_modal: false)}
  end

  def handle_event("select_rule", %{"value" => id}, socket) do
    rules = socket.assigns.available_rules
    rule = Enum.find(rules, &(&1["id"] == id))

    if rule do
      form = to_form(%{
        "keywords" => Enum.join(Map.get(rule, "keywords", []), ", "),
        "location" => Map.get(rule, "location", "Brazil"),
        "source" => Map.get(rule, "source", "all")
      })

      {:noreply,
       socket
       |> assign(form: form, selected_rule: rule, show_rules_modal: false)
       |> put_flash(:info, "Regra '#{rule["name"]}' selecionada!")}
    else
      {:noreply, assign(socket, show_rules_modal: false)}
    end
  end

  def handle_info({:run_search, params, selected_rule}, socket) do
    keywords = Map.get(params, "keywords", "")
    location = Map.get(params, "location", "Brazil")
    source = Map.get(params, "source", "all")

    # Aplica filtros da regra se houver
    filters = if selected_rule, do: Map.get(selected_rule, "filters", %{}), else: %{}

    # Simulação de busca (implementar integração real depois)
    jobs = search_simulated(keywords, location, source, filters)

    existing = JobsStore.load()
    updated = (existing ++ jobs) |> Enum.uniq_by(fn job -> job["external_id"] end)
    JobsStore.save(updated)

    socket = socket
    |> assign(loading: false, jobs: jobs)

    {:noreply, socket}
  end

  defp search_simulated(keywords, _location, source, filters) do
    sources = if source == "all", do: ["linkedin", "indeed", "gupy"], else: [source]

    Enum.flat_map(sources, fn src ->
      %{
        "external_id" => "#{src}_#{:crypto.hash(:sha256, keywords) |> Base.encode16()}",
        "title" => "Vaga de #{keywords} em #{src}",
        "company" => "Empresa Exemplo",
        "location" => "São Paulo, SP",
        "url" => "https://exemplo.com/vaga",
        "source" => src,
        "work_type" => "Remoto",
        "created_at" => DateTime.utc_now(),
        "filters_applied" => filters
      }
    end)
  end

  defp load_rule(path) when is_binary(path) do
    cond do
      File.exists?(path) ->
        path |> File.read!() |> Jason.decode!()
      String.ends_with?(path, ".json") ->
        # Tenta caminho absoluto ou relativo ao projeto
        expanded = Path.expand(path)
        if File.exists?(expanded) do
          expanded |> File.read!() |> Jason.decode!()
        else
          nil
        end
      true ->
        # Busca na pasta padrao
        default_path = "priv/rules/#{path}.json"
        if File.exists?(default_path) do
          default_path |> File.read!() |> Jason.decode!()
        else
          nil
        end
    end
  rescue
    _ -> nil
  end

  defp load_all_rules do
    path = "priv/rules"
    if File.exists?(path) do
      path
      |> Path.join("*.json")
      |> Path.wildcard()
      |> Enum.map(fn file -> File.read!(file) |> Jason.decode!() end)
      |> List.flatten()
    else
      []
    end
  rescue
    _ -> []
  end
end