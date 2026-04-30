defmodule AutoVagasWeb.SettingsLive do
  use AutoVagasWeb, :live_view

  alias AutoVagasWeb.I18n

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="max-w-6xl mx-auto p-6">
        <div class="mb-6">
          <h1 class="text-3xl font-bold text-base-content"><%= I18n.t(@locale, "settings") %></h1>
          <p class="text-base-content/60"><%= I18n.t(@locale, "profiles") %></p>
        </div>

        <!-- Tabs -->
        <div class="tabs tabs-boxed mb-6">
          <a class={"tab " <> if(@active_tab == "profiles", do: "tab-active", else: "")}
             phx-click="switch_tab" phx-value="profiles">
            Perfis
          </a>
          <a class={"tab " <> if(@active_tab == "integrations", do: "tab-active", else: "")}
             phx-click="switch_tab" phx-value="integrations">
            Integrações
          </a>
          <a class={"tab " <> if(@active_tab == "notifications", do: "tab-active", else: "")}
             phx-click="switch_tab" phx-value="notifications">
            Notificações
          </a>
          <a class={"tab " <> if(@active_tab == "general", do: "tab-active", else: "")}
             phx-click="switch_tab" phx-value="general">
            Geral
          </a>
        </div>

        <!-- Profiles Tab -->
        <div :if={@active_tab == "profiles"}>
          <section class="bg-base-200 border border-base-300 rounded-lg p-6">
            <div class="flex items-center justify-between mb-4">
              <h2 class="text-xl font-semibold text-base-content">Perfis de Busca</h2>
              <button phx-click="add_profile" class="btn btn-primary btn-sm">
                Novo Perfil
              </button>
            </div>

            <div class="space-y-4">
              <div
                :for={{id, profile} <- @streams.profiles}
                id={id}
                class="border border-base-300 rounded-lg p-4 bg-base-100"
              >
                <.form
                  for={@profile_forms[id]}
                  phx-submit="update_profile"
                  phx-value-index={profile.index}
                  class="space-y-4"
                >
                  <div class="flex gap-4 items-start">
                    <div class="flex-1">
                      <label class="block text-sm font-medium text-base-content mb-1">
                        Nome do Perfil
                      </label>
                      <.input
                        field={@profile_forms[id][:name]}
                        type="text"
                        placeholder="ex: Analista de Redes"
                        class="w-full"
                      />
                    </div>
                    <button
                      type="button"
                      phx-click="remove_profile"
                      phx-value-index={profile.index}
                      class="btn btn-error btn-sm mt-8"
                    >
                      ✕
                    </button>
                  </div>

                  <div>
                    <label class="block text-sm font-medium text-base-content mb-1">
                      Palavras-chave
                    </label>
                    <.input
                      field={@profile_forms[id][:keywords]}
                      type="text"
                      placeholder="palavras-chave..."
                      class="w-full"
                    />
                  </div>

                  <div class="grid grid-cols-2 gap-4">
                    <div>
                      <label class="block text-sm font-medium text-base-content mb-1">
                        Tecnologias
                      </label>
                      <.input
                        field={@profile_forms[id][:resources]}
                        type="text"
                        placeholder="ex: python, docker"
                        class="w-full"
                      />
                    </div>
                    <div>
                      <label class="block text-sm font-medium text-base-content mb-1">
                        Funções
                      </label>
                      <.input
                        field={@profile_forms[id][:job_roles]}
                        type="text"
                        placeholder="ex: analista"
                        class="w-full"
                      />
                    </div>
                  </div>

                  <div class="flex justify-end">
                    <button type="submit" class="btn btn-primary btn-sm">
                      Salvar Perfil
                    </button>
                  </div>
                </.form>
              </div>
            </div>

            <div :if={@profiles == []} class="text-center py-4 text-base-content/50">
              <button phx-click="add_profile" class="btn btn-primary">
                Criar Primeiro Perfil
              </button>
            </div>
          </section>
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
                      <%= case @auth_status["linkedin"] do
                        :active -> "Ativo"
                        :configured -> "Configurado"
                        :error -> "Erro"
                        _ -> "Inativo"
                      end %>
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
            </div>
          </section>

          <!-- SSO Help -->
          <div class="mt-4">
            <.link navigate="/ajuda" class="btn btn-sm btn-ghost">
              Ajuda com integrações →
            </.link>
          </div>
        </div>

        <!-- Notifications Tab -->
        <div :if={@active_tab == "notifications"}>
          <section class="bg-base-200 border border-base-300 rounded-lg p-6">
            <h2 class="text-xl font-semibold text-base-content mb-4">Canais de Notificação</h2>
            <p class="text-sm text-base-content/60 mb-6">
              Apenas um canal pode estar ativo por vez.
            </p>

            <div class="space-y-4">
              <div class="border border-base-300 rounded-lg p-4 bg-base-100">
                <div class="flex items-center justify-between">
                  <div>
                    <h3 class="font-medium text-base-content">WhatsApp</h3>
                    <p class="text-sm text-base-content/60">WhatsApp Business</p>
                  </div>
                  <input
                    type="radio"
                    name="notification_channel"
                    class="radio radio-primary"
                    phx-click="toggle_channel"
                    phx-value-channel="whatsapp"
                    checked={@selected_channel == "whatsapp"}
                  />
                </div>
                <div class="mt-2">
                  <button phx-click="config_channel" phx-value-channel="whatsapp" class="btn btn-sm btn-outline btn-primary">
                    Configurar
                  </button>
                </div>
              </div>

              <div class="border border-base-300 rounded-lg p-4 bg-base-100">
                <div class="flex items-center justify-between">
                  <div>
                    <h3 class="font-medium text-base-content">Telegram</h3>
                    <p class="text-sm text-base-content/60">Bot do Telegram</p>
                  </div>
                  <input
                    type="radio"
                    name="notification_channel"
                    class="radio radio-primary"
                    phx-click="toggle_channel"
                    phx-value-channel="telegram"
                    checked={@selected_channel == "telegram"}
                  />
                </div>
                <div class="mt-2">
                  <button phx-click="config_channel" phx-value-channel="telegram" class="btn btn-sm btn-outline btn-primary">
                    Configurar
                  </button>
                </div>
              </div>

              <div class="border border-base-300 rounded-lg p-4 bg-base-100">
                <div class="flex items-center justify-between">
                  <div>
                    <h3 class="font-medium text-base-content">Discord</h3>
                    <p class="text-sm text-base-content/60">Webhook</p>
                  </div>
                  <input
                    type="radio"
                    name="notification_channel"
                    class="radio radio-primary"
                    phx-click="toggle_channel"
                    phx-value-channel="discord"
                    checked={@selected_channel == "discord"}
                  />
                </div>
                <div class="mt-2">
                  <button phx-click="config_channel" phx-value-channel="discord" class="btn btn-sm btn-outline btn-primary">
                    Configurar
                  </button>
                </div>
              </div>
            </div>
          </section>
        </div>

        <!-- General Tab -->
        <div :if={@active_tab == "general"}>
          <!-- Location -->
          <section class="bg-base-200 border border-base-300 rounded-lg p-6 mb-4">
            <h2 class="text-xl font-semibold text-base-content mb-4">Sua Localização</h2>
            <div class="grid grid-cols-3 gap-4">
              <div>
                <label class="block text-sm font-medium text-base-content mb-1">País</label>
                <input
                  type="text"
                  name="user_country"
                  value={@user_location["country"]}
                  placeholder="Brasil"
                  class="input input-bordered w-full"
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-base-content mb-1">Estado</label>
                <input
                  type="text"
                  name="user_state"
                  value={@user_location["state"]}
                  placeholder="SP"
                  class="input input-bordered w-full"
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-base-content mb-1">Cidade</label>
                <input
                  type="text"
                  name="user_city"
                  value={@user_location["city"]}
                  placeholder="São Paulo"
                  class="input input-bordered w-full"
                />
              </div>
            </div>
          </section>

          <!-- Languages and Filters -->
          <section class="bg-base-200 border border-base-300 rounded-lg p-6 mb-4">
            <h2 class="text-xl font-semibold text-base-content mb-4">Configurações Gerais</h2>

            <.form for={@form} id="general-form" class="space-y-4">
              <div class="grid grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-base-content mb-1">Localização Padrão</label>
                  <.input field={@form[:location]} type="text" placeholder="Brazil" class="w-full" />
                </div>

                <div>
                  <label class="block text-sm font-medium text-base-content mb-1">Idiomas</label>
                  <div class="flex flex-wrap gap-2 mb-2">
                    <span :for={lang <- @selected_languages} class="badge badge-primary gap-1">
                      <%= I18n.t(@locale, lang) %>
                      <button phx-click="remove_language" phx-value={lang} class="btn btn-ghost btn-xs">✕</button>
                    </span>
                  </div>
                  <select
                    name="language"
                    class="select select-bordered w-full"
                    phx-change="add_language"
                  >
                    <option value="">Adicionar idioma</option>
                    <option :for={{label, code} <- I18n.language_options(@locale)} value={code}>
                      <%= label %>
                    </option>
                  </select>
                </div>
              </div>

              <div class="grid grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-base-content mb-1">Tempo de Postagem</label>
                  <.input
                    field={@form[:time_posted]}
                    type="select"
                    options={I18n.time_options(@locale)}
                    class="w-full"
                  />
                </div>

                <div>
                  <label class="block text-sm font-medium text-base-content mb-1">Tipo de Trabalho</label>
                  <.input
                    field={@form[:work_type]}
                    type="select"
                    options={I18n.work_options(@locale)}
                    class="w-full"
                  />
                </div>
              </div>
            </.form>
          </section>

          <!-- Import Resume -->
          <section class="bg-base-200 border border-base-300 rounded-lg p-6 mb-4">
            <h2 class="text-xl font-semibold text-base-content mb-4">Importar Currículo</h2>

            <div class="mb-4">
              <button phx-click="toggle_help" class="btn btn-ghost btn-sm">
                <%= if @show_help, do: "Fechar Ajuda", else: "Ajuda" %>
              </button>
            </div>

            <div :if={@show_help} class="alert alert-info mb-4">
              <div>
                <strong>Como exportar:</strong>
                <ol class="list-decimal list-inside text-sm mt-2">
                  <li>LinkedIn → Mais → Salvar em PDF</li>
                </ol>
              </div>
            </div>

            <div
              id="upload-dropzone"
              phx-drop="set-upload"
              class="flex flex-col items-center justify-center w-full h-32 border-2 border-dashed border-base-300 rounded-lg cursor-pointer hover:border-primary transition-colors"
            >
              <div class="flex flex-col items-center justify-center">
                <svg xmlns="http://www.w3.org/2000/svg" class="w-8 h-8 mb-2 text-base-content/60" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
                </svg>
                <p class="text-sm text-base-content/60">
                  <%= if @uploading, do: "Processando...", else: "Clique ou arraste um PDF" %>
                </p>
              </div>
            </div>

            <form id="upload-form" phx-submit="save_upload">
              <input
                type="file"
                id="pdf-upload"
                name="pdf"
                accept=".pdf"
                class="hidden"
                phx-upload="set-upload"
              />
              <button :if={@uploads.pdf.entries != []} type="submit" class="btn btn-primary mt-4">
                Processar Currículo
              </button>
            </form>

            <div :if={@upload_message} class={"alert mt-4 " <> if(@upload_error, do: "alert-error", else: "alert-success")}>
              <%= @upload_message %>
            </div>
          </section>
        </div>

        <!-- Save Button -->
        <div class="flex justify-end mt-6">
          <button phx-click="save_all" class="btn btn-primary">
            <%= I18n.t(@locale, "save_all") %>
          </button>
        </div>
      </div>

      <!-- Credentials Modal -->
      <%= if @show_creds_modal do %>
        <div class="modal modal-open">
          <div class="modal-box">
            <h3 class="font-bold text-lg mb-4">Credenciais - <%= String.capitalize(@creds_source) %></h3>

            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium mb-1">Client ID</label>
                <input
                  type="text"
                  class="input input-bordered w-full"
                  value={@creds_client_id}
                  phx-keyup="update_creds_field"
                  phx-value-field="client_id"
                />
              </div>

              <div>
                <label class="block text-sm font-medium mb-1">Client Secret</label>
                <input
                  type="password"
                  class="input input-bordered w-full"
                  value={@creds_client_secret}
                  phx-keyup="update_creds_field"
                  phx-value-field="client_secret"
                />
                <p class="text-xs text-base-content/60 mt-1">Criptografado com AES-256</p>
              </div>
            </div>

            <div class="modal-action">
              <button phx-click="hide_creds_modal" class="btn btn-ghost">Cancelar</button>
              <button phx-click="save_creds" class="btn btn-primary">Salvar</button>
            </div>
          </div>
        </div>
      <% end %>
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

    {:ok,
     socket
     |> assign(:active_page, "configuracoes")
     |> assign(:active_tab, "profiles")
     |> assign(form: form, work_form: work_form, language_input: language_input)
     |> assign(profiles: profiles, profile_forms: profile_forms)
     |> assign(selected_languages: selected_languages)
     |> assign(user_location: user_location)
     |> assign(auth_status: auth_status, notification_status: notification_status, selected_channel: selected_channel)
     |> assign(show_help: false, uploading: false, upload_message: nil, upload_error: false)
     |> assign(show_creds_modal: false, creds_source: nil, creds_client_id: "", creds_client_secret: "")
     |> stream_configure(:profiles, dom_id: &"profile-#{&1.index}")
     |> stream(:profiles, profiles, reset: true)
     |> allow_upload(:pdf, accept: [".pdf"], max_entries: 1, max_file_size: 10_000_000)}
  end

  def handle_event("switch_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :active_tab, tab)}
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

    encrypted_secret = AutoVagas.Crypto.encrypt(client_secret)

    auth_config = load_auth_config()
    updated = put_in(auth_config, [source, "client_id"], client_id)
    updated = put_in(updated, [source, "client_secret"], encrypted_secret)

    save_auth_config(updated)

    {:noreply,
     socket
     |> assign(show_creds_modal: false, creds_source: nil)
     |> assign(auth_status: load_auth_status())}
  end

  def handle_event("add_profile", _params, socket) do
    new_profile = %{
      index: length(socket.assigns.profiles),
      name: "",
      keywords: [],
      resources: [],
      job_roles: []
    }

    profiles = socket.assigns.profiles ++ [new_profile]
    profile_forms = build_profile_forms(profiles)

    {:noreply,
     socket
     |> assign(profiles: profiles, profile_forms: profile_forms)
     |> stream(:profiles, profiles, reset: true)}
  end

  def handle_event("remove_profile", %{"index" => index}, socket) do
    idx = String.to_integer(index)
    profiles = List.delete_at(socket.assigns.profiles, idx)
    profile_forms = build_profile_forms(profiles)

    {:noreply,
     socket
     |> assign(profiles: profiles, profile_forms: profile_forms)
     |> stream(:profiles, profiles, reset: true)}
  end

  def handle_event("update_profile", _params, socket), do: {:noreply, socket}

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

    {entries_to_upload, socket} =
      Enum.reduce(entries, {[], socket}, fn entry, {acc, socket} ->
        [path] =
          consume_uploaded_entries(socket, :pdf, fn %{path: path}, _entry -> {:ok, path} end)

        Process.send(self(), {:process_upload, path, entry.client_name}, [])

        {[{entry.ref, path} | acc], socket}
      end)

    socket =
      socket
      |> cancel_upload(:pdf, entries_to_upload)
      |> assign(uploading: true, upload_message: nil)

    {:noreply, socket}
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
end
