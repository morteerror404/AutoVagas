defmodule AutoVagasWeb.RotinasLive do
  use AutoVagasWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_page={@active_page}>
      <div class="max-w-6xl mx-auto p-6">
        <div class="mb-6">
          <h1 class="text-3xl font-bold text-base-content">Rotinas de Busca</h1>
          <p class="text-base-content/60">Configure regras para busca automática de vagas</p>
        </div>

        <div class="mb-4">
          <button phx-click="new_rule" class="btn btn-primary btn-sm">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
            </svg>
            Nova Rotina
          </button>
        </div>

        <div class="space-y-4">
          <div :if={@rules == []} class="text-center py-8 text-base-content/50">
            <p class="text-sm">Nenhuma rotina configurada</p>
            <p class="text-xs mt-2">Clique em "Nova Rotina" para começar</p>
          </div>

          <div :for={rule <- @rules} id={"rule-#{rule["id"]}"} class="p-4 bg-base-100 rounded border border-base-300">
            <div class="flex justify-between items-start mb-3">
              <div class="flex-1">
                <div class="flex items-center gap-2 mb-2">
                  <div class={"w-2 h-2 rounded-full " <> if(rule["active"], do: "bg-success", else: "bg-base-300")}></div>
                  <h3 class="font-semibold text-base-content"><%= rule["name"] || "Sem nome" %></h3>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-2 mb-3">
                  <div>
                    <span class="text-xs text-base-content/60">Palavras-chave:</span>
                    <p class="text-sm"><%= Enum.join(rule["keywords"] || [], ", ") || "Nenhuma" %></p>
                  </div>
                  <div>
                    <span class="text-xs text-base-content/60">Localização:</span>
                    <p class="text-sm"><%= rule["location"] || "Nenhuma" %></p>
                  </div>
                </div>

                <div class="flex gap-2 flex-wrap">
                  <span class="badge badge-sm"><%= rule["source"] || "linkedin" %></span>
                  <span class={"badge badge-sm " <> if(rule["active"], do: "badge-success", else: "badge-ghost")}>
                    <%= if rule["active"], do: "Ativa", else: "Inativa" %>
                  </span>
                  <span class="badge badge-sm"><%= rule["schedule"] || "diária" %></span>
                  <span :if={rule["filters"]} class="badge badge-sm badge-outline">Com filtros</span>
                </div>
              </div>

              <div class="flex gap-1">
                <button phx-click="edit_rule" phx-value={rule["id"]} class="btn btn-xs btn-ghost">
                  Editar
                </button>
                <button phx-click="toggle_rule" phx-value={rule["id"]} class="btn btn-xs btn-ghost">
                  <%= if rule["active"], do: "Desativar", else: "Ativar" %>
                </button>
                <button phx-click="delete_rule" phx-value={rule["id"]} class="btn btn-xs btn-error btn-ghost">
                  Excluir
                </button>
              </div>
            </div>

            <!-- Filtros resumidos -->
            <div :if={rule["filters"]} class="mt-3 pt-3 border-t border-base-300">
              <details class="text-sm">
                <summary class="cursor-pointer text-base-content/70">Ver filtros aplicados</summary>
                <pre class="mt-2 p-2 bg-base-200 rounded text-xs overflow-x-auto"><%= Jason.encode!(rule["filters"], pretty: true) %></pre>
              </details>
            </div>
          </div>
        </div>

        <div class="mt-6 bg-base-100 rounded-lg p-4 border border-base-300">
          <h3 class="font-semibold text-base-content mb-2">Como usar</h3>
          <ul class="text-sm text-base-content/70 space-y-1">
            <li>1. Crie rotinas com palavras-chave e filtros desejados</li>
            <li>2. Ative as rotinas que deseja executar automaticamente</li>
            <li>3. Acesse a página "Vagas" para importar e executar as rotinas</li>
            <li>4. O sistema buscará vagas automaticamente conforme o agendamento</li>
          </ul>
        </div>
      </div>

      <!-- Modal de edição/criação -->
      <div class={"modal " <> if(@show_modal, do: "modal-open", else: "")}>
        <div class="modal-box">
          <h3 class="font-bold text-lg mb-4"><%= if @editing_rule, do: "Editar", else: "Nova" %> Rotina</h3>

          <.form for={@rule_form} phx-submit="save_rule" class="space-y-4">
            <div class="form-control">
              <label class="label"><span class="label-text">Nome da rotina</span></label>
              <.input field={@rule_form[:name]} type="text" class="w-full input-bordered" />
            </div>

            <div class="form-control">
              <label class="label"><span class="label-text">Palavras-chave (separadas por vírgula)</span></label>
              <.input field={@rule_form[:keywords]} type="text" placeholder="elixir, phoenix, erlang" class="w-full input-bordered" />
            </div>

            <div class="grid grid-cols-2 gap-4">
              <div class="form-control">
                <label class="label"><span class="label-text">Localização</span></label>
                <.input field={@rule_form[:location]} type="text" placeholder="Brazil" class="w-full input-bordered" />
              </div>

              <div class="form-control">
                <label class="label"><span class="label-text">Fonte</span></label>
                <.input field={@rule_form[:source]} type="select"
                  options={[{"Todas", "all"}, {"LinkedIn", "linkedin"}, {"Indeed", "indeed"}, {"Gupy", "gupy"}]}
                  class="w-full select-bordered" />
              </div>
            </div>

            <div class="form-control">
              <label class="label"><span class="label-text">Agendamento</span></label>
              <.input field={@rule_form[:schedule]} type="select"
                options={[{"Diário", "daily"}, {"Semanal", "weekly"}, {"Mensal", "monthly"}]}
                class="w-full select-bordered" />
            </div>

            <div class="divider">Filtros</div>

            <div class="form-control">
              <label class="label"><span class="label-text">Classificar por</span></label>
              <.input field={@rule_form[:sort_by]} type="select"
                options={[{"Mais recentes", "recent"}, {"Mais relevantes", "relevant"}]}
                class="w-full select-bordered" />
            </div>

            <div class="form-control">
              <label class="label"><span class="label-text">Data do anúncio</span></label>
              <.input field={@rule_form[:time_posted]} type="select"
                options={[{"A qualquer momento", "any"}, {"Último mês", "r2592000"}, {"Última semana", "r604800"}, {"Últimas 24 horas", "r86400"}]}
                class="w-full select-bordered" />
            </div>

            <div class="form-control">
              <label class="label"><span class="label-text">Nível de experiência</span></label>
              <.input field={@rule_form[:experience_level]} type="select"
                options={[{"Todos", ""}, {"Estágio", "internship"}, {"Assistente", "assistant"}, {"Júnior", "junior"}, {"Pleno-sênior", "mid_senior"}, {"Diretor", "director"}, {"Executivo", "executive"}]}
                class="w-full select-bordered" />
            </div>

            <div class="form-control">
              <label class="label"><span class="label-text">Tipo de vaga</span></label>
              <.input field={@rule_form[:work_type]} type="select"
                options={[{"Todos", ""}, {"Tempo integral", "full_time"}, {"Meio período", "part_time"}, {"Contrato", "contract"}, {"Temporário", "temporary"}, {"Voluntário", "volunteer"}, {"Estágio", "internship"}, {"Outro", "other"}]}
                class="w-full select-bordered" />
            </div>

            <div class="form-control">
              <label class="label"><span class="label-text">Remoto</span></label>
              <.input field={@rule_form[:remote_type]} type="select"
                options={[{"Todos", ""}, {"Presencial", "on_site"}, {"Híbrido", "hybrid"}, {"Remoto", "remote"}]}
                class="w-full select-bordered" />
            </div>

            <div class="form-control">
              <label class="label cursor-pointer">
                <.input field={@rule_form[:linkedin_easy_apply]} type="checkbox" class="checkbox" />
                <span class="label-text ml-2">Candidatura via LinkedIn</span>
              </label>
            </div>

            <div class="form-control">
              <label class="label cursor-pointer">
                <.input field={@rule_form[:verified_only]} type="checkbox" class="checkbox" />
                <span class="label-text ml-2">Tem verificações</span>
              </label>
            </div>

            <div class="form-control">
              <label class="label cursor-pointer">
                <.input field={@rule_form[:less_than_10_applicants]} type="checkbox" class="checkbox" />
                <span class="label-text ml-2">Menos de 10 candidaturas</span>
              </label>
            </div>

            <div class="form-control">
              <label class="label cursor-pointer">
                <.input field={@rule_form[:in_network]} type="checkbox" class="checkbox" />
                <span class="label-text ml-2">Na sua rede</span>
              </label>
            </div>

            <div class="form-control">
              <label class="label cursor-pointer">
                <.input field={@rule_form[:second_chance]} type="checkbox" class="checkbox" />
                <span class="label-text ml-2">Empresas que dão segundas chances</span>
              </label>
            </div>

            <div class="form-control">
              <label class="label"><span class="label-text">Compromissos</span></label>
              <.input field={@rule_form[:commitments]} type="select"
                options={[{"Todos", ""}, {"Diversidade, equidade e inclusão", "dei"}, {"Equilíbrio vida pessoal/profissional", "work_life"}, {"Impacto social", "social_impact"}, {"Plano de carreira", "career_growth"}, {"Sustentabilidade ambiental", "environmental"}]}
                class="w-full select-bordered" />
            </div>

            <div class="form-control">
              <label class="label"><span class="label-text">Setor (opcional)</span></label>
              <.input field={@rule_form[:sector]} type="text" class="w-full input-bordered" />
            </div>

            <div class="form-control">
              <label class="label"><span class="label-text">Função (opcional)</span></label>
              <.input field={@rule_form[:job_function]} type="text" class="w-full input-bordered" />
            </div>

            <div class="form-control">
              <label class="label"><span class="label-text">Cargo (opcional)</span></label>
              <.input field={@rule_form[:job_title]} type="text" class="w-full input-bordered" />
            </div>

            <div class="modal-action">
              <button type="button" phx-click="hide_modal" class="btn btn-ghost">Cancelar</button>
              <button type="submit" class="btn btn-primary">Salvar</button>
            </div>
          </.form>
        </div>
        <form phx-click="hide_modal" class="modal-backdrop"></form>
      </div>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    rules = load_rules()

    socket = assign(socket, active_page: "rotinas")
    {:ok, assign(socket, rules: rules, show_modal: false, editing_rule: nil, rule_form: nil)}
  end

  def handle_event("new_rule", _, socket) do
    form = to_form(%{
      "name" => "Nova Rotina",
      "keywords" => "",
      "location" => "Brazil",
      "source" => "all",
      "schedule" => "daily",
      "sort_by" => "recent",
      "time_posted" => "r86400",
      "experience_level" => "",
      "work_type" => "",
      "remote_type" => "",
      "linkedin_easy_apply" => false,
      "verified_only" => false,
      "less_than_10_applicants" => false,
      "in_network" => false,
      "second_chance" => false,
      "commitments" => "",
      "sector" => "",
      "job_function" => "",
      "job_title" => ""
    })

    {:noreply, assign(socket, show_modal: true, editing_rule: nil, rule_form: form)}
  end

  def handle_event("edit_rule", %{"value" => id}, socket) do
    rules = socket.assigns.rules
    rule = Enum.find(rules, &(&1["id"] == id))

    if rule do
      filters = Map.get(rule, "filters", %{})

      form = to_form(%{
        "name" => Map.get(rule, "name", ""),
        "keywords" => (Map.get(rule, "keywords", []) |> Enum.join(", ")),
        "location" => Map.get(rule, "location", "Brazil"),
        "source" => Map.get(rule, "source", "all"),
        "schedule" => Map.get(rule, "schedule", "daily"),
        "sort_by" => Map.get(filters, "sort_by", "recent"),
        "time_posted" => Map.get(filters, "time_posted", "r86400"),
        "experience_level" => Map.get(filters, "experience_level", ""),
        "work_type" => Map.get(filters, "work_type", ""),
        "remote_type" => Map.get(filters, "remote_type", ""),
        "linkedin_easy_apply" => Map.get(filters, "linkedin_easy_apply", false),
        "verified_only" => Map.get(filters, "verified_only", false),
        "less_than_10_applicants" => Map.get(filters, "less_than_10_applicants", false),
        "in_network" => Map.get(filters, "in_network", false),
        "second_chance" => Map.get(filters, "second_chance", false),
        "commitments" => Map.get(filters, "commitments", ""),
        "sector" => Map.get(filters, "sector", ""),
        "job_function" => Map.get(filters, "job_function", ""),
        "job_title" => Map.get(filters, "job_title", "")
      })

      {:noreply, assign(socket, show_modal: true, editing_rule: rule, rule_form: form)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("save_rule", params, socket) do
    form_data = params["rule"] || params
    rules = socket.assigns.rules
    editing_rule = socket.assigns.editing_rule

    keywords = parse_list(Map.get(form_data, "keywords", ""))
    filters = %{
      "sort_by" => Map.get(form_data, "sort_by", "recent"),
      "time_posted" => Map.get(form_data, "time_posted", "r86400"),
      "experience_level" => Map.get(form_data, "experience_level", ""),
      "work_type" => Map.get(form_data, "work_type", ""),
      "remote_type" => Map.get(form_data, "remote_type", ""),
      "linkedin_easy_apply" => Map.get(form_data, "linkedin_easy_apply", "false") == "true",
      "verified_only" => Map.get(form_data, "verified_only", "false") == "true",
      "less_than_10_applicants" => Map.get(form_data, "less_than_10_applicants", "false") == "true",
      "in_network" => Map.get(form_data, "in_network", "false") == "true",
      "second_chance" => Map.get(form_data, "second_chance", "false") == "true",
      "commitments" => Map.get(form_data, "commitments", ""),
      "sector" => Map.get(form_data, "sector", ""),
      "job_function" => Map.get(form_data, "job_function", ""),
      "job_title" => Map.get(form_data, "job_title", "")
    }
    |> Enum.reject(fn {_, v} -> v == "" or v == false end)
    |> Map.new()

    if editing_rule do
      updated_rules = Enum.map(rules, fn rule ->
        if Map.get(rule, "id") == Map.get(editing_rule, "id") do
          Map.merge(rule, %{
            "name" => Map.get(form_data, "name", rule["name"]),
            "keywords" => keywords,
            "location" => Map.get(form_data, "location", rule["location"]),
            "source" => Map.get(form_data, "source", rule["source"]),
            "schedule" => Map.get(form_data, "schedule", rule["schedule"]),
            "filters" => filters
          })
        else
          rule
        end
      end)

      save_rules(updated_rules)
      {:noreply, assign(socket, rules: updated_rules, show_modal: false, editing_rule: nil, rule_form: nil)}
    else
      new_rule = %{
        "id" => System.unique_integer([:positive]),
        "name" => Map.get(form_data, "name", "Nova Rotina"),
        "keywords" => keywords,
        "location" => Map.get(form_data, "location", "Brazil"),
        "source" => Map.get(form_data, "source", "all"),
        "schedule" => Map.get(form_data, "schedule", "daily"),
        "active" => true,
        "filters" => filters,
        "created_at" => DateTime.utc_now() |> DateTime.to_iso8601()
      }

      updated_rules = rules ++ [new_rule]
      save_rules(updated_rules)
      {:noreply, assign(socket, rules: updated_rules, show_modal: false, editing_rule: nil, rule_form: nil)}
    end
  end

  def handle_event("toggle_rule", %{"value" => id}, socket) do
    rules = socket.assigns.rules

    updated_rules = Enum.map(rules, fn rule ->
      if Map.get(rule, "id") == id do
        Map.put(rule, "active", not Map.get(rule, "active", false))
      else
        rule
      end
    end)

    save_rules(updated_rules)
    {:noreply, assign(socket, rules: updated_rules)}
  end

  def handle_event("delete_rule", %{"value" => id}, socket) do
    rules = socket.assigns.rules
    updated_rules = Enum.reject(rules, &(&1["id"] == id))
    save_rules(updated_rules)
    {:noreply, assign(socket, rules: updated_rules)}
  end

  def handle_event("hide_modal", _, socket) do
    {:noreply, assign(socket, show_modal: false, editing_rule: nil, rule_form: nil)}
  end

  defp load_rules do
    path = "priv/rules/rules.json"
    if File.exists?(path) do
      path |> File.read!() |> Jason.decode!()
    else
      []
    end
  rescue
    _ -> []
  end

  defp save_rules(rules) do
    path = "priv/rules/rules.json"
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, Jason.encode!(rules, pretty: true))
  end

  defp parse_list(""), do: []
  defp parse_list(s) when is_binary(s) do
    s |> String.split(",") |> Enum.map(&String.trim/1) |> Enum.reject(&(&1 == ""))
  end
  defp parse_list(l), do: l
end
