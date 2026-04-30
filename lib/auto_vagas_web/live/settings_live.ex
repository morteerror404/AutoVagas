defmodule AutoVagasWeb.SettingsLive do
  use AutoVagasWeb, :live_view

  alias AutoVagasWeb.I18n

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_page={@active_page}>
      <div class="max-w-6xl mx-auto p-6">
        <div class="mb-6">
          <h1 class="text-3xl font-bold text-base-content"><%= I18n.t(@locale, "settings") %></h1>
          <p class="text-base-content/60">Configurações do sistema</p>
        </div>

        <!-- Tabs -->
        <div class="tabs tabs-boxed mb-6">
          <a class={"tab " <> if(@active_tab == "integrations", do: "tab-active", else: "")}
             phx-click="switch_tab" phx-value="integrations">
            Integrações
          </a>
          <a class={"tab " <> if(@active_tab == "notifications", do: "tab-active", else: "")}
             phx-click="switch_tab" phx-value="notifications">
            Notificações
          </a>
          <a class={"tab " <> if(@active_tab == "rules", do: "tab-active", else: "")}
             phx-click="switch_tab" phx-value="rules">
            Regras
          </a>
          <a class={"tab " <> if(@active_tab == "general", do: "tab-active", else: "")}
             phx-click="switch_tab" phx-value="general">
            Geral
          </a>
          <.link navigate="/perfil" class={"tab " <> if(@active_page == "perfil", do: "tab-active", else: "")}>
            Perfil
          </.link>
        </div>

        <!-- Integrations Tab -->
        <div :if={@active_tab == "integrations"}>
          <section class="bg-base-200 border border-base-300 rounded-lg p-6">
            <h2 class="text-xl font-bold text-base-content mb-4">Integrações e Autenticação</h2>
            <p class="text-sm text-base-content/60 mb-6">
              Configure a autenticação para sites que exigem login.
            </p>

            <div class="space-y-4">
              <!-- LinkedIn -->
              <div class="border border-base-300 rounded-lg p-4 bg-base-100">
                <div class="flex items-center justify-between mb-3">
                  <div>
                    <h3 class="font-medium text-base-content">LinkedIn</h3>
                    <p class="text-sm text-base-content/60">OAuth 2.0</p>
                  </div>
                  <div class="flex items-center gap-2">
                    <span class={
                      "w-3 h-3 rounded-full " <>
                      case @auth_status["linkedin"] do
                        :active -> "bg-success"
                        :configured -> "bg-success"
                        :error -> "bg-error"
                        _ -> "border-2 border-base-300"
                      end
                    }></span>
                    <span class="text-sm">
                      <%= auth_status_label(@auth_status["linkedin"]) %>
                    </span>
                  </div>
                </div>
                <div class="flex gap-2">
                  <button phx-click="show_creds_modal" phx-value-source="linkedin" class="btn btn-sm btn-outline btn-primary">
                    Credenciais
                  </button>
                  <%= if @auth_status["linkedin"] in [:inactive, :error] do %>
                    <.link href={AutoVagas.Auth.LinkedIn.authorize_url()} class="btn btn-sm btn-primary">
                      Conectar
                    </.link>
                  <% end %>
                </div>
              </div>

              <!-- Indeed -->
              <div class="border border-base-300 rounded-lg p-4 bg-base-100">
                <div class="flex items-center justify-between mb-3">
                  <div>
                    <h3 class="font-medium text-base-content">Indeed</h3>
                    <p class="text-sm text-base-content/60">OAuth 2.0</p>
                  </div>
                  <span class="text-sm text-base-content/60">Em breve</span>
                </div>
              </div>

              <!-- Gupy -->
              <div class="border border-base-300 rounded-lg p-4 bg-base-100">
                <div class="flex items-center justify-between mb-3">
                  <div>
                    <h3 class="font-medium text-base-content">Gupy</h3>
                    <p class="text-sm text-base-content/60">SAML 2.0</p>
                  </div>
                  <span class="text-sm text-base-content/60">Em breve</span>
                </div>
              </div>

              <!-- RapidAPI - LinkedIn Job Search -->
              <div class="border border-base-300 rounded-lg p-4 bg-base-100">
                <div class="flex items-center justify-between mb-3">
                  <div>
                    <h3 class="font-medium text-base-content">RapidAPI - LinkedIn Jobs</h3>
                    <p class="text-sm text-base-content/60">Busca de vagas via API</p>
                  </div>
                  <span class={
                    "w-3 h-3 rounded-full " <>
                      if(@rapidapi_configured, do: "bg-success", else: "border-2 border-base-300")
                  }></span>
                </div>
                <div class="flex gap-2">
                  <button phx-click="show_rapidapi_modal" class="btn btn-sm btn-outline btn-primary">
                    Configurar
                  </button>
                  <.link href="https://rapidapi.com/fantastic-jobs-fantastic-jobs-default/api/linkedin-job-search-api" class="btn btn-sm btn-ghost" target="_blank">
                    Documentação →
                  </.link>
                </div>
              </div>
            </div>

            <div class="mt-4">
              <.link navigate="/ajuda" class="btn btn-sm btn-ghost">
                Ajuda com integrações →
              </.link>
            </div>
          </section>
        </div>

        <!-- Rules Tab -->
        <div :if={@active_tab == "rules"}>
          <section class="bg-base-200 border border-base-300 rounded-lg p-6">
            <div class="flex justify-between items-center mb-6">
              <div>
                <h2 class="text-xl font-bold text-base-content">Regras de Automação</h2>
                <p class="text-sm text-base-content/60">Gerencie regras para busca automática de vagas</p>
              </div>
              <button phx-click="new_rule" class="btn btn-primary btn-sm">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                </svg>
                Nova Regra
              </button>
            </div>

            <div class="space-y-3">
              <div :if={@rules == []} class="text-center py-8 text-base-content/50">
                <p class="text-sm">Nenhuma regra configurada</p>
                <p class="text-xs mt-2">Clique em "Nova Regra" para começar</p>
              </div>

              <div :for={rule <- @rules} class="p-4 bg-base-100 rounded border border-base-300 hover:shadow-md transition-shadow">
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
                      <%= if rule["active"], do: "Desativar", else: "Ativar" %>
                    </button>
                    <button phx-click="delete_rule" phx-value={rule["id"]} class="btn btn-xs btn-error btn-ghost">
                      Excluir
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <div class="mt-6 bg-base-100 rounded-lg p-4 border border-base-300">
              <h3 class="font-semibold text-base-content mb-2">Como usar</h3>
              <ul class="text-sm text-base-content/70 space-y-1">
                <li>1. Crie regras com palavras-chave e filtros desejados</li>
                <li>2. Ative as regras que deseja executar automaticamente</li>
                <li>3. Acesse a página "Vagas" para importar e executar as regras</li>
                <li>4. O sistema buscará vagas automaticamente conforme o agendamento</li>
              </ul>
            </div>
          </section>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    detected_locale = I18n.detect_language(socket)

    user_info = load_user_info()

    user_location =
      Map.get(user_info, "user_location", %{"country" => "Brazil", "state" => "", "city" => ""})

    form =
      to_form(%{
        "location" => Map.get(user_info, "location", "Brazil"),
        "time_posted" => get_in(user_info, ["default_filters", "time_posted"]) || "r86400",
        "work_type" => get_in(user_info, ["default_filters", "work_type"]) || "all"
      })

    language_input = to_form(%{"language" => ""})

    work_configs =
      Map.get(user_info, "work_configs", %{
        "on_site" => %{"max_distance_km" => 30, "countries" => []},
        "hybrid" => %{"max_distance_km" => 50, "countries" => []},
        "remote" => %{"max_distance_km" => nil, "countries" => []}
      })

    work_form =
      to_form(%{
        "on_site_distance" => get_in(work_configs, ["on_site", "max_distance_km"]) |> to_string(),
        "on_site_countries" => get_in(work_configs, ["on_site", "countries"]) |> Enum.join(", "),
        "hybrid_distance" => get_in(work_configs, ["hybrid", "max_distance_km"]) |> to_string(),
        "hybrid_countries" => get_in(work_configs, ["hybrid", "countries"]) |> Enum.join(", "),
        "remote_distance" => get_in(work_configs, ["remote", "max_distance_km"]) |> to_string(),
        "remote_countries" => get_in(work_configs, ["remote", "countries"]) |> Enum.join(", ")
      })

    profiles = Map.get(user_info, "profiles", [])
    profile_forms = build_profile_forms(profiles)
    selected_languages = Map.get(user_info, "languages", [])

    auth_status = load_auth_status()
    notification_status = load_notification_status()
    selected_channel = get_selected_channel(notification_status)

    socket = assign(socket, :locale, detected_locale)

    rapidapi_configured = load_rapidapi_key() != ""

    {:ok,
     socket
     |> assign(:active_page, "configuracoes")
     |> assign(:active_tab, "integrations")
     |> assign(form: form, work_form: work_form, language_input: language_input)
     |> assign(profiles: profiles, profile_forms: profile_forms)
     |> assign(selected_languages: selected_languages)
     |> assign(user_location: user_location)
     |> assign(auth_status: auth_status, notification_status: notification_status, selected_channel: selected_channel)
     |> assign(show_help: false, uploading: false, upload_message: nil, upload_error: false)
     |> assign(show_creds_modal: false, creds_source: nil, creds_client_id: "", creds_client_secret: "")
     |> assign(show_rapidapi_modal: false, rapidapi_key: load_rapidapi_key(), rapidapi_configured: rapidapi_configured)
     |> stream_configure(:profiles, dom_id: &"profile-#{&1.index}")
     |> stream(:profiles, profiles, reset: true)
     |> allow_upload(:pdf, accept: [".pdf"], max_entries: 1, max_file_size: 10_000_000)}
  end

  def handle_event("switch_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, active_tab: tab)}
  end

  def handle_event("toggle_help", _, socket),
    do: {:noreply, assign(socket, show_help: not socket.assigns.show_help)}

  def handle_event("show_creds_modal", %{"source" => source}, socket) do
    {:noreply, assign(socket, show_creds_modal: true, creds_source: source, creds_client_id: "", creds_client_secret: "")}
  end

  def handle_event("hide_creds_modal", _, socket) do
    {:noreply, assign(socket, show_creds_modal: false, creds_source: nil)}
  end

  def handle_event("update_creds_field", %{"field" => field, "value" => value}, socket) do
    socket =
      case field do
        "client_id" -> assign(socket, creds_client_id: value)
        "client_secret" -> assign(socket, creds_client_secret: value)
        _ -> socket
      end
    {:noreply, socket}
  end

  def handle_event("save_creds", _, socket) do
    source = socket.assigns.creds_source
    client_id = socket.assigns.creds_client_id
    client_secret = socket.assigns.creds_client_secret

    encrypted_secret = AutoVagas.Auth.Crypto.encrypt(client_secret)

    auth_config = load_auth_config()
    updated = put_in(auth_config, [source, "client_id"], client_id)
    updated = put_in(updated, [source, "client_secret"], encrypted_secret)

    save_auth_config(updated)

    {:noreply,
     socket
     |> assign(show_creds_modal: false, creds_source: nil)
     |> assign(auth_status: load_auth_status())}
  end

  def handle_event("show_rapidapi_modal", _, socket) do
    {:noreply, assign(socket, show_rapidapi_modal: true, rapidapi_key: load_rapidapi_key())}
  end

  def handle_event("hide_rapidapi_modal", _, socket) do
    {:noreply, assign(socket, show_rapidapi_modal: false)}
  end

  def handle_event("update_rapidapi_field", %{"field" => field, "value" => value}, socket) do
    socket =
      case field do
        "api_key" -> assign(socket, rapidapi_key: value)
        _ -> socket
      end
    {:noreply, socket}
  end

  def handle_event("save_rapidapi", _, socket) do
    api_key = socket.assigns.rapidapi_key || ""

    if api_key != "" do
      encrypted_key = AutoVagas.Auth.Crypto.encrypt(api_key)

      auth_config = load_auth_config()
      updated = put_in(auth_config, ["rapidapi", "linkedin_job_search", "api_key"], encrypted_key)
      save_auth_config(updated)

      {:noreply,
       socket
        |> assign(show_rapidapi_modal: false, rapidapi_configured: true)
        |> put_flash(:info, "RapIDAPI configurado com sucesso!")}
    else
      {:noreply, put_flash(socket, :error, "Informe a API key")}
    end
  end

  def handle_event("add_language", %{"language" => lang}, socket) do
    if lang != "" and lang not in socket.assigns.selected_languages do
      updated = socket.assigns.selected_languages ++ [lang]
      {:noreply, assign(socket, selected_languages: updated)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("toggle_channel", %{"channel" => channel}, socket) do
    notification_status = socket.assigns.notification_status
    selected_channel = socket.assigns.selected_channel

    {updated_status, new_selected} =
      if selected_channel == channel do
        {Map.put(notification_status, channel, false), nil}
      else
        base = Map.new(notification_status, fn {k, _} -> {k, false} end)
        {Map.put(base, channel, true), channel}
      end

    {:noreply, assign(socket, notification_status: updated_status, selected_channel: new_selected)}
  end

  def handle_event("remove_language", %{"language" => lang}, socket) do
    updated = List.delete(socket.assigns.selected_languages, lang)
    {:noreply, assign(socket, selected_languages: updated)}
  end

  def handle_event("save_upload", _params, socket) do
    entries = socket.assigns.uploads.pdf.entries

    case entries do
      [entry | _] ->
        # Consume o arquivo enviado
        {[path], socket} =
          consume_uploaded_entries(socket, :pdf, fn %{path: path}, _entry -> {:ok, path} end)

        # Envia para processamento assíncrono
        Process.send(self(), {:process_upload, path, entry.client_name}, [])

        socket =
          socket
          |> cancel_upload(:pdf, [entry])
          |> assign(uploading: true, upload_message: nil)

        {:noreply, socket}

      [] ->
        {:noreply, put_flash(socket, :error, "Nenhum arquivo selecionado")}
    end
  end

  # Rule Management Handlers
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
    user_info = load_user_info()
    updated = Map.put(user_info, "rules", updated_rules)
    save_user_info(updated)

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

    user_info = load_user_info()
    updated = Map.put(user_info, "rules", updated_rules)
    save_user_info(updated)

    {:noreply, assign(socket, rules: updated_rules)}
  end

  def handle_event("delete_rule", %{"value" => id}, socket) do
    rules = socket.assigns.rules
    updated_rules = Enum.reject(rules, fn rule -> Map.get(rule, "id") == id end)

    user_info = load_user_info()
    updated = Map.put(user_info, "rules", updated_rules)
    save_user_info(updated)

    {:noreply, assign(socket, rules: updated_rules)}
  end


  def handle_event(
        "save_all",
        %{"user_country" => country, "user_state" => state, "user_city" => city},
        socket
      ) do
    form = socket.assigns.form
    work_form = socket.assigns.work_form

    updated_profiles =
      Enum.map(socket.assigns.profiles, fn profile ->
        form_key = "profile-#{profile.index}"
        profile_form = Map.get(socket.assigns.profile_forms, form_key)

        if profile_form do
          %{
            index: profile.index,
            name: profile_form[:name].value,
            keywords: parse_list(profile_form[:keywords].value),
            resources: parse_list(profile_form[:resources].value),
            job_roles: parse_list(profile_form[:job_roles].value)
          }
        else
          profile
        end
      end)

    current_user_info = load_user_info()

    user_info = %{
      "user_location" => %{
        "country" => country,
        "state" => state,
        "city" => city
      },
      "location" => form[:location].value,
      "languages" => socket.assigns.selected_languages,
      "default_filters" => %{
        "time_posted" => form[:time_posted].value,
        "work_type" => form[:work_type].value
      },
      "profiles" => updated_profiles,
      "work_configs" => %{
        "on_site" => %{
          "max_distance_km" => parse_number(work_form[:on_site_distance].value),
          "countries" => parse_list(work_form[:on_site_countries].value)
        },
        "hybrid" => %{
          "max_distance_km" => parse_number(work_form[:hybrid_distance].value),
          "countries" => parse_list(work_form[:hybrid_countries].value)
        },
        "remote" => %{
          "max_distance_km" => parse_number(work_form[:remote_distance].value),
          "countries" => parse_list(work_form[:remote_countries].value)
        }
      },
      "filters" => Map.get(current_user_info, "filters", %{}),
      "rules" => Map.get(current_user_info, "rules", [])
    }

    save_user_info(user_info)
    {:noreply, put_flash(socket, :info, "Configurações salvas!")}
  end

  def handle_info({:process_upload, path, _filename}, socket) do
    case extract_pdf_content(path) do
      {:ok, _text} ->
        new_profile = %{
          index: length(socket.assigns.profiles),
          name: "Importado",
          keywords: [],
          resources: [],
          job_roles: []
        }

        profiles = socket.assigns.profiles ++ [new_profile]
        profile_forms = build_profile_forms(profiles)
        save_user_info(Map.put(load_user_info(), "profiles", profiles))

        {:noreply,
         assign(socket,
           uploading: false,
           upload_message: "Currículo importado!",
           upload_error: false,
           profiles: profiles,
           profile_forms: profile_forms
         )}

      {:error, msg} ->
        {:noreply, assign(socket, uploading: false, upload_message: msg, upload_error: true)}
    end
  end

  defp build_profile_forms(profiles) do
    Enum.reduce(profiles, %{}, fn profile, acc ->
      form =
        to_form(%{
          "name" => Map.get(profile, "name", ""),
          "keywords" => Map.get(profile, "keywords", []) |> Enum.join(", "),
          "resources" => Map.get(profile, "resources", []) |> Enum.join(", "),
          "job_roles" => Map.get(profile, "job_roles", []) |> Enum.join(", ")
        }, as: "profile_#{profile.index}")

      Map.put(acc, "profile-#{profile.index}", form)
    end)
  end

  defp parse_number(""), do: nil
  defp parse_number(n) when is_binary(n), do: String.to_integer(n)
  defp parse_number(n), do: n

  defp parse_list(""), do: []
  defp parse_list(s) when is_binary(s),
    do: s |> String.split(",") |> Enum.map(&String.trim/1) |> Enum.reject(&(&1 == ""))
  defp parse_list(l), do: l

  defp load_user_info do
    path = "priv/user_info.json"
    if File.exists?(path), do: path |> File.read!() |> Jason.decode!(), else: %{}
  rescue
    _ -> %{}
  end

  defp load_rules do
    user_info = load_user_info()
    Map.get(user_info, "rules", [])
  end

  defp save_rules(rules) do
    user_info = load_user_info()
    updated = Map.put(user_info, "rules", rules)
    save_user_info(updated)
  end

  defp load_auth_status do
    user_info = load_user_info()
    %{
      "linkedin" => Map.get(user_info, "linkedin_auth", false),
      "indeed" => Map.get(user_info, "indeed_auth", false),
      "gupy" => Map.get(user_info, "gupy_auth", false)
    }
  end

  defp load_notification_status do
    user_info = load_user_info()
    channels = Map.get(user_info, "notification_channels", %{})

    %{
      "whatsapp" => Map.get(channels, "whatsapp", %{}) |> Map.get("enabled", false),
      "telegram" => Map.get(channels, "telegram", %{}) |> Map.get("enabled", false),
      "discord" => Map.get(channels, "discord", %{}) |> Map.get("enabled", false)
    }
  end

  defp get_selected_channel(notification_status) do
    cond do
      notification_status["whatsapp"] -> "whatsapp"
      notification_status["telegram"] -> "telegram"
      notification_status["discord"] -> "discord"
      true -> nil
    end
  end

  defp load_auth_config do
    case File.read("priv/filters/auth_config.json") do
      {:ok, content} -> Jason.decode!(content)
      _ -> %{}
    end
  end

  defp save_auth_config(config) do
    File.write!("priv/filters/auth_config.json", Jason.encode!(config, pretty: true))
  end

  defp save_user_info(info) do
    File.write!("priv/user_info.json", Jason.encode!(info, pretty: true))
  end

  defp extract_pdf_content(path) do
    try do
      case System.cmd("pdftotext", ["-layout", path, "-"]) do
        {text, 0} -> {:ok, text}
        _ -> {:error, "Erro ao extrair"}
      end
    rescue
      _ -> {:error, "Erro ao processar"}
    end
  end

  defp auth_status_label(:active), do: "Ativo"
  defp auth_status_label(:configured), do: "Configurado"
  defp auth_status_label(:error), do: "Erro"
  defp auth_status_label(_), do: "Inativo"

  defp load_rapidapi_key do
    try do
      path = "priv/filters/auth_config.json"
      case File.read(path) do
        {:ok, content} ->
          config = Jason.decode!(content)
          case get_in(config, ["rapidapi", "linkedin_job_search", "api_key"]) do
            nil -> nil
            encrypted_key -> AutoVagas.Auth.Crypto.decrypt(encrypted_key)
          end
        _ -> nil
      end
    rescue
      _ -> nil
    end
  end

end
