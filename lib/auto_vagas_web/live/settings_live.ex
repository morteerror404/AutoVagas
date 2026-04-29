defmodule AutoVagasWeb.SettingsLive do
  use AutoVagasWeb, :live_view

  alias AutoVagasWeb.I18n

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="max-w-4xl mx-auto p-6">
        <h1 class="text-3xl font-bold text-base-content mb-2">{I18n.t(@locale, "settings")}</h1>
        <p class="text-base-content/60 mb-8">{I18n.t(@locale, "profiles")}</p>

        <div class="space-y-8">
          <section class="bg-base-200 border border-base-300 rounded-lg p-6">
            <div class="flex items-center justify-between mb-4">
              <h2 class="text-xl font-semibold text-base-content">{I18n.t(@locale, "profiles")}</h2>
              <button phx-click="add_profile" class="btn btn-primary btn-sm">
                {I18n.t(@locale, "new_profile")}
              </button>
            </div>

            <div class="space-y-4">
              <div
                :for={{id, profile} <- @streams.profiles}
                id={id}
                class="border border-base-300 rounded-lg p-4"
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
                        {I18n.t(@locale, "profile_name")}
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
                      {I18n.t(@locale, "keywords")}
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
                        {I18n.t(@locale, "technologies")}
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
                        {I18n.t(@locale, "roles")}
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
                      {I18n.t(@locale, "save_all")} Perfil
                    </button>
                  </div>
                </.form>
              </div>
            </div>

            <div :if={@profiles == []} class="text-center py-4 text-base-content/50">
              <button phx-click="add_profile" class="btn btn-primary">
                {I18n.t(@locale, "create_profile")}
              </button>
          </div>
        </section>

        <section class="bg-base-200 border border-base-300 rounded-lg p-6">
          <h2 class="text-xl font-bold text-base-content mb-4">Integrações e Autenticação</h2>
          <p class="text-sm text-base-content/60 mb-4">
            Configure a autenticação para sites que exigem login e gerencie integrações de notificações.
          </p>

          <div class="space-y-4">
            <!-- LinkedIn SSO Card -->
            <div class="border border-base-300 rounded-lg p-4">
              <div class="flex items-center justify-between mb-2">
                <div class="flex-1">
                  <div class="flex items-center gap-2">
                    <h3 class="font-medium text-base-content">LinkedIn</h3>
                    <%= if @auth_status["linkedin"] == :active do %>
                      <span class="w-3 h-3 rounded-full bg-success inline-block" title="Ativo"></span>
                    <% end %>
                    <%= if @auth_status["linkedin"] == :configured do %>
                      <span class="w-3 h-3 rounded-full bg-success inline-block" title="Configurado"></span>
                    <% end %>
                    <%= if @auth_status["linkedin"] == :inactive do %>
                      <span class="w-3 h-3 rounded-full border-2 border-base-300 inline-block" title="Inativo"></span>
                    <% end %>
                    <%= if @auth_status["linkedin"] == :error do %>
                      <span class="w-3 h-3 rounded-full bg-error inline-block" title="Erro"></span>
                    <% end %>
                  </div>
                  <p class="text-sm text-base-content/60">OAuth 2.0 - Autenticacao SSO</p>
                  <a href="/ajuda" class="link link-primary text-xs">Ajuda para configurar</a>
                </div>
              </div>

              <div class="flex items-center justify-between">
                <div>
                  <%= if @auth_status["linkedin"] == :active do %>
                    <span class="text-sm text-success">● Ativo</span>
                  <% end %>
                  <%= if @auth_status["linkedin"] == :configured do %>
                    <span class="text-sm text-success">[Configurado]</span>
                  <% end %>
                  <%= if @auth_status["linkedin"] == :inactive do %>
                    <span class="text-sm text-base-content/60">○ Nao configurado</span>
                  <% end %>
                  <%= if @auth_status["linkedin"] == :error do %>
                    <span class="text-sm text-error">[Erro na conexao]</span>
                  <% end %>
                </div>

                <div class="flex gap-2">
                  <button phx-click="show_creds_modal" phx-value-source="linkedin" class="btn btn-sm btn-outline btn-primary">
                    Adicionar Credenciais
                  </button>

                  <%= if @auth_status["linkedin"] == :configured do %>
                    <.link href={AutoVagas.Auth.LinkedIn.authorize_url()} class="btn btn-primary btn-sm">
                      Reconectar
                    </.link>
                  <% end %>

                  <%= if @auth_status["linkedin"] == :inactive do %>
                    <.link href={AutoVagas.Auth.LinkedIn.authorize_url()} class="btn btn-primary btn-sm">
                      Integrar
                    </.link>
                  <% end %>

                  <%= if @auth_status["linkedin"] == :error do %>
                    <button phx-click="retry_auth" phx-value-source="linkedin" class="btn btn-error btn-sm">
                      Tentar Novamente
                    </button>
                  <% end %>
                </div>
              </div>
            </div>

            <!-- Indeed SSO Card -->
            <div class="border border-base-300 rounded-lg p-4">
              <div class="flex items-center justify-between mb-2">
                <div class="flex-1">
                  <div class="flex items-center gap-2">
                    <h3 class="font-medium text-base-content">Indeed</h3>
                    <%= if @auth_status["indeed"] == :active do %>
                      <span class="w-3 h-3 rounded-full bg-success inline-block" title="Ativo"></span>
                    <% end %>
                    <%= if @auth_status["indeed"] == :configured do %>
                      <span class="w-3 h-3 rounded-full bg-success inline-block" title="Configurado"></span>
                    <% end %>
                    <%= if @auth_status["indeed"] == :inactive do %>
                      <span class="w-3 h-3 rounded-full border-2 border-base-300 inline-block" title="Inativo"></span>
                    <% end %>
                    <%= if @auth_status["indeed"] == :error do %>
                      <span class="w-3 h-3 rounded-full bg-error inline-block" title="Erro"></span>
                    <% end %>
                  </div>
                  <p class="text-sm text-base-content/60">OAuth 2.0 / SSO - Candidatos e Empresas</p>
                </div>
              </div>

              <div class="flex items-center justify-between">
                <div>
                  <%= if @auth_status["indeed"] == :active do %>
                    <span class="text-sm text-success">● Ativo</span>
                  <% end %>
                  <%= if @auth_status["indeed"] == :configured do %>
                    <span class="text-sm text-success">✓ Configurado</span>
                  <% end %>
                  <%= if @auth_status["indeed"] == :inactive do %>
                    <span class="text-sm text-base-content/60">○ Não configurado</span>
                  <% end %>
                  <%= if @auth_status["indeed"] == :error do %>
                    <span class="text-sm text-error">✕ Erro na conexão</span>
                  <% end %>
                </div>

                <div>
                  <%= if @auth_status["indeed"] == :inactive do %>
                    <button phx-click="integrate_sso" phx-value-source="indeed" class="btn btn-primary btn-sm">
                      Integrar
                    </button>
                  <% end %>

                  <%= if @auth_status["indeed"] == :error do %>
                    <button phx-click="retry_auth" phx-value-source="indeed" class="btn btn-error btn-sm">
                      Tentar Novamente
                    </button>
                  <% end %>
                </div>
              </div>
            </div>

            <!-- Gupy SSO Card -->
            <div class="border border-base-300 rounded-lg p-4">
              <div class="flex items-center justify-between mb-2">
                <div class="flex-1">
                  <div class="flex items-center gap-2">
                    <h3 class="font-medium text-base-content">Gupy</h3>
                    <%= if @auth_status["gupy"] == :active do %>
                      <span class="w-3 h-3 rounded-full bg-success inline-block" title="Ativo"></span>
                    <% end %>
                    <%= if @auth_status["gupy"] == :configured do %>
                      <span class="w-3 h-3 rounded-full bg-success inline-block" title="Configurado"></span>
                    <% end %>
                    <%= if @auth_status["gupy"] == :inactive do %>
                      <span class="w-3 h-3 rounded-full border-2 border-base-300 inline-block" title="Inativo"></span>
                    <% end %>
                    <%= if @auth_status["gupy"] == :error do %>
                      <span class="w-3 h-3 rounded-full bg-error inline-block" title="Erro"></span>
                    <% end %>
                  </div>
                  <p class="text-sm text-base-content/60">SAML 2.0 - Autenticação Corporativa</p>
                </div>
              </div>

              <div class="flex items-center justify-between">
                <div>
                  <%= if @auth_status["gupy"] == :active do %>
                    <span class="text-sm text-success">● Ativo</span>
                  <% end %>
                  <%= if @auth_status["gupy"] == :configured do %>
                    <span class="text-sm text-success">✓ Configurado</span>
                  <% end %>
                  <%= if @auth_status["gupy"] == :inactive do %>
                    <span class="text-sm text-base-content/60">○ Não configurado</span>
                  <% end %>
                  <%= if @auth_status["gupy"] == :error do %>
                    <span class="text-sm text-error">✕ Erro na conexão</span>
                  <% end %>
                </div>

                <div>
                  <%= if @auth_status["gupy"] == :inactive do %>
                    <button phx-click="integrate_sso" phx-value-source="gupy" class="btn btn-primary btn-sm">
                      Integrar
                    </button>
                  <% end %>

                  <%= if @auth_status["gupy"] == :error do %>
                    <button phx-click="retry_auth" phx-value-source="gupy" class="btn btn-error btn-sm">
                      Tentar Novamente
                    </button>
                  <% end %>
                </div>
              </div>
            </div>
          </div>
        </section>

        <!-- SSO Difficulties Section -->
        <section class="bg-base-200 border border-base-300 rounded-lg p-6 mt-4">
          <h3 class="text-lg font-semibold text-base-content mb-3">Dificuldades para Implementar SSO</h3>

          <div class="space-y-3">
            <div class="p-3 bg-base-100 rounded">
              <h4 class="font-medium text-base-content">LinkedIn OAuth 2.0</h4>
              <ul class="text-sm text-base-content/80 mt-2 space-y-1">
                <li><strong>[Facil]</strong> Fluxo padrao OAuth 2.0 com Authorization Code</li>
                <li>Documentacao oficial clara da API</li>
                <li>Biblioteca Req ja configurada</li>
                <li><strong>[Atencao]</strong> Precisa de <code>client_id</code> e <code>client_secret</code> validos</li>
              </ul>
            </div>

            <div class="p-3 bg-base-100 rounded">
              <h4 class="font-medium text-base-content">Indeed OAuth 2.0</h4>
              <ul class="text-sm text-base-content/80 mt-2 space-y-1">
                <li><strong>[Medio]</strong> Dois fluxos diferentes (Candidatos vs Empresas)</li>
                <li><strong>[Atencao]</strong> Documentacao limitada para integracao via SSO</li>
                <li><strong>[Atencao]</strong> Pode exigir configuracao especial no portal do desenvolvedor</li>
                <li><strong>[Pendente]</strong> Implementacao atual e apenas estrutural (sem token real)</li>
              </ul>
            </div>

            <div class="p-3 bg-base-100 rounded">
              <h4 class="font-medium text-base-content">Gupy SAML 2.0</h4>
              <ul class="text-sm text-base-content/80 mt-2 space-y-1">
                <li><strong>[Dificil]</strong> SAML 2.0 e complexo (XML, assinaturas digitais)</li>
                <li><strong>[Pendente]</strong> Requer certificado X.509 (chave publica/privada)</li>
                <li><strong>[Pendente]</strong> Phoenix nao tem suporte nativo a SAML (precisa de biblioteca como <code>samly</code>)</li>
                <li><strong>[Pendente]</strong> Gupy pode exigir whitelist de IP/dominio da aplicacao</li>
                <li><strong>[Pendente]</strong> Implementacao atual e apenas estrutural (sem fluxo real)</li>
              </ul>
            </div>
          </div>
        </section>

        <section class="bg-base-200 border border-base-300 rounded-lg p-6">
          <h2 class="text-xl font-semibold text-base-content mb-4">Canais de Notificacao</h2>
          <p class="text-sm text-base-content/60 mb-4">
            Configure canis para receber alertas de vagas pendentes. Apenas um canal pode estar ativo por vez.
          </p>

          <div class="space-y-4">
            <div class="border border-base-300 rounded-lg p-4">
              <div class="flex items-center justify-between mb-2">
                <div>
                  <h3 class="font-medium text-base-content">WhatsApp</h3>
                  <p class="text-sm text-base-content/60">Alertas via WhatsApp Business</p>
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
              <div :if={@notification_status["whatsapp"]} class="text-sm text-success">
                [Ativo]
              </div>
              <div class="mt-2">
                <button phx-click="config_channel" phx-value-channel="whatsapp" class="btn btn-sm btn-outline btn-primary">
                  Configurar WhatsApp
                </button>
              </div>
            </div>

            <div class="border border-base-300 rounded-lg p-4">
              <div class="flex items-center justify-between mb-2">
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
              <div :if={@notification_status["telegram"]} class="text-sm text-success">
                [Ativo]
              </div>
              <div class="mt-2">
                <button phx-click="config_channel" phx-value-channel="telegram" class="btn btn-sm btn-outline btn-primary">
                  Configurar Telegram
                </button>
              </div>
            </div>

            <div class="border border-base-300 rounded-lg p-4">
              <div class="flex items-center justify-between mb-2">
                <div>
                  <h3 class="font-medium text-base-content">Discord</h3>
                  <p class="text-sm text-base-content/60">Webhook do Discord</p>
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
              <div :if={@notification_status["discord"]} class="text-sm text-success">
                [Ativo]
              </div>
              <div class="mt-2">
                <button phx-click="config_channel" phx-value-channel="discord" class="btn btn-sm btn-outline btn-primary">
                  Configurar Discord
                </button>
              </div>
            </div>
          </div>
        </section>

        <section class="bg-base-200 border border-base-300 rounded-lg p-6">
          <h2 class="text-xl font-semibold text-base-content mb-4">
            Sua Localização
          </h2>
            <p class="text-sm text-base-content/60 mb-4">
              Informe sua localização para calcular distâncias das vagas.
            </p>

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
                <label class="block text-sm font-medium text-base-content mb-1">
                  Estado/Província
                </label>
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

          <section class="bg-base-200 border border-base-300 rounded-lg p-6">
            <h2 class="text-xl font-semibold text-base-content mb-4">
              {I18n.t(@locale, "general_settings")}
            </h2>

            <.form for={@form} id="general-form" class="space-y-4">
              <div class="grid grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-base-content mb-1">
                    {I18n.t(@locale, "location")}
                  </label>
                  <.input field={@form[:location]} type="text" placeholder="Brazil" class="w-full" />
                </div>

                <div>
                  <label class="block text-sm font-medium text-base-content mb-1">
                    {I18n.t(@locale, "languages")}
                  </label>
                  <div class="flex flex-wrap gap-2 mb-2">
                    <span :for={lang <- @selected_languages} class="badge badge-primary gap-1">
                      {I18n.t(@locale, lang)}
                      <button
                        phx-click="remove_language"
                        phx-value={lang}
                        class="btn btn-ghost btn-xs"
                      >
                        ✕
                      </button>
                    </span>
                  </div>
                  <select
                    name="language"
                    id="language-select"
                    class="select select-bordered w-full"
                    phx-change="add_language"
                  >
                    <option value="">{I18n.t(@locale, "add_language")}</option>
                    <option :for={{label, code} <- I18n.language_options(@locale)} value={code}>
                      {label}
                    </option>
                  </select>
                </div>
              </div>

              <div class="grid grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-base-content mb-1">
                    {I18n.t(@locale, "time_posted")}
                  </label>
                  <.input
                    field={@form[:time_posted]}
                    type="select"
                    options={I18n.time_options(@locale)}
                    class="w-full"
                  />
                </div>

                <div>
                  <label class="block text-sm font-medium text-base-content mb-1">
                    {I18n.t(@locale, "work_type")}
                  </label>
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

          <section class="bg-base-200 border border-base-300 rounded-lg p-6">
            <h2 class="text-xl font-semibold text-base-content mb-4">
              {I18n.t(@locale, "work_config")}
            </h2>

            <.form for={@work_form} id="work-form" class="space-y-4">
              <div class="grid grid-cols-3 gap-4">
                <div class="border border-base-300 rounded-lg p-4">
                  <h3 class="font-medium text-base-content mb-2">
                    {I18n.t(@locale, "on_site_config")}
                  </h3>
                  <div class="space-y-2">
                    <div>
                      <label class="block text-xs text-base-content/60 mb-1">
                        {I18n.t(@locale, "max_distance")}
                      </label>
                      <.input
                        field={@work_form[:on_site_distance]}
                        type="number"
                        placeholder="30"
                        class="w-full"
                      />
                    </div>
                    <div>
                      <label class="block text-xs text-base-content/60 mb-1">
                        {I18n.t(@locale, "countries")}
                      </label>
                      <.input
                        field={@work_form[:on_site_countries]}
                        type="text"
                        placeholder="Brazil, USA..."
                        class="w-full"
                      />
                    </div>
                  </div>
                </div>

                <div class="border border-base-300 rounded-lg p-4">
                  <h3 class="font-medium text-base-content mb-2">
                    {I18n.t(@locale, "hybrid_config")}
                  </h3>
                  <div class="space-y-2">
                    <div>
                      <label class="block text-xs text-base-content/60 mb-1">
                        {I18n.t(@locale, "max_distance")}
                      </label>
                      <.input
                        field={@work_form[:hybrid_distance]}
                        type="number"
                        placeholder="50"
                        class="w-full"
                      />
                    </div>
                    <div>
                      <label class="block text-xs text-base-content/60 mb-1">
                        {I18n.t(@locale, "countries")}
                      </label>
                      <.input
                        field={@work_form[:hybrid_countries]}
                        type="text"
                        placeholder="Brazil, USA..."
                        class="w-full"
                      />
                    </div>
                  </div>
                </div>

                <div class="border border-base-300 rounded-lg p-4">
                  <h3 class="font-medium text-base-content mb-2">
                    {I18n.t(@locale, "remote_config")}
                  </h3>
                  <div class="space-y-2">
                    <div>
                      <label class="block text-xs text-base-content/60 mb-1">
                        {I18n.t(@locale, "max_distance")}
                      </label>
                      <.input
                        field={@work_form[:remote_distance]}
                        type="number"
                        placeholder="1000"
                        class="w-full"
                      />
                    </div>
                    <div>
                      <label class="block text-xs text-base-content/60 mb-1">
                        {I18n.t(@locale, "countries")}
                      </label>
                      <.input
                        field={@work_form[:remote_countries]}
                        type="text"
                        placeholder="Brazil, USA..."
                        class="w-full"
                      />
                    </div>
                  </div>
                </div>
              </div>
            </.form>
          </section>

          <section class="bg-base-200 border border-base-300 rounded-lg p-6">
            <div class="flex items-center justify-between mb-4">
              <h2 class="text-xl font-semibold text-base-content">
                {I18n.t(@locale, "import_resume")}
              </h2>
              <button phx-click="toggle_help" class="btn btn-ghost btn-sm">
                {if @show_help, do: I18n.t(@locale, "close_help"), else: I18n.t(@locale, "help")}
              </button>
            </div>

            <div :if={@show_help} class="alert alert-info mb-4">
              <div>
                <strong class="block text-base-content mb-2">
                  {I18n.t(@locale, "how_to_export")}
                </strong>
                <ol class="list-decimal list-inside text-sm text-base-content/80 space-y-1">
                  <li>LinkedIn → Mais → Salvar em PDF</li>
                </ol>
              </div>
            </div>

            <div :if={not @show_help} class="space-y-4">
              <div
                id="upload-dropzone"
                phx-drop="set-upload"
                class="flex flex-col items-center justify-center w-full h-32 border-2 border-dashed border-base-300 rounded-lg cursor-pointer hover:border-primary transition-colors"
              >
                <div class="flex flex-col items-center justify-center">
                  <.icon name="hero-document-arrow-up" class="w-8 h-8 mb-2 text-base-content/60" />
                  <p class="text-sm text-base-content/60">
                    {if @uploading, do: "Processando...", else: I18n.t(@locale, "upload_pdf")}
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
                <button :if={@uploads.pdf.entries != []} type="submit" class="btn btn-primary">
                  {I18n.t(@locale, "process_resume")}
                </button>
              </form>

              <div
                :if={@upload_message}
                class="alert {if @upload_error, do: 'alert-error', else: 'alert-success'}"
              >
                {@upload_message}
              </div>
            </div>
          </section>

          <div class="flex justify-end">
            <button phx-click="save_all" class="btn btn-primary btn-lg">
              {I18n.t(@locale, "save_all")}
            </button>
          </div>
        </div>
         </div>

      <!-- Modal de Credenciais -->
      <%= if @show_creds_modal do %>
        <div class="modal modal-open">
          <div class="modal-box">
            <h3 class="font-bold text-lg mb-4">Adicionar Credenciais - <%= @creds_source |> String.capitalize() %></h3>

            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium mb-1">Client ID</label>
                <input
                  type="text"
                  class="input input-bordered w-full"
                  value={@creds_client_id}
                  phx-keyup="update_creds_field"
                  phx-value-field="client_id"
                  phx-debounce="0"
                />
              </div>

              <div>
                <label class="block text-sm font-medium mb-1">Primary Client Secret</label>
                <input
                  type="password"
                  class="input input-bordered w-full"
                  value={@creds_client_secret}
                  phx-keyup="update_creds_field"
                  phx-value-field="client_secret"
                  phx-debounce="0"
                />
                <p class="text-xs text-base-content/60 mt-1">Criptografado com AES-256 antes de salvar</p>
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

    # Load auth and notification statuses
    auth_status = load_auth_status()
    notification_status = load_notification_status()
    selected_channel = get_selected_channel(notification_status)

    socket = assign(socket, :locale, detected_locale)

    {:ok,
     socket
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

  def handle_event("toggle_auth", %{"source" => source}, socket) do
    auth_status = socket.assigns.auth_status
    current = Map.get(auth_status, source, false)
    updated = Map.put(auth_status, source, not current)

    # Here you would trigger the actual auth flow
    # For now, we just toggle the status
    {:noreply, assign(socket, auth_status: updated)}
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

  def handle_event("integrate_sso", %{"source" => source}, socket) do
    cond do
      source == "linkedin" ->
        url = AutoVagas.Auth.LinkedIn.authorize_url()
        {:noreply, redirect(socket, external: url)}
      source == "indeed" ->
        # Implement Indeed OAuth flow
        {:noreply, socket}
      source == "gupy" ->
        # Implement Gupy SAML flow
        {:noreply, socket}
      true ->
        {:noreply, socket}
    end
  end

  def handle_event("retry_auth", %{"source" => source}, socket) do
    # Retry logic for failed auth
    auth_status = socket.assigns.auth_status
    updated = Map.put(auth_status, source, :inactive)
    {:noreply, assign(socket, auth_status: updated)}
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
        form = socket.assigns.profile_forms["profile-#{profile.index}"]

        %{
          index: profile.index,
          name: form[:name].value,
          keywords: parse_list(form[:keywords].value),
          resources: parse_list(form[:resources].value),
          job_roles: parse_list(form[:job_roles].value)
        }
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
    {:noreply, put_flash(socket, :info, "Salvo!")}
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
    # Check if auth sessions exist for each source
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
