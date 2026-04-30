defmodule AutoVagasWeb.HelpLive do
  use AutoVagasWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="flex flex-col md:flex-row max-w-6xl mx-auto p-6 gap-6">
        <!-- Sidebar Navigation -->
        <aside class="w-full md:w-64 flex-shrink-0">
          <div class="bg-base-200 rounded-lg p-4">
            <h2 class="font-bold text-base-content mb-4">Guias de Integração</h2>
            <ul class="menu menu-compact space-y-1">
              <li>
                <a href="#linkedin" class={"text-sm " <> if(@active_section == "linkedin", do: "active", else: "")}>
                  LinkedIn OAuth 2.0
                </a>
              </li>
              <li>
                <a href="#indeed" class={"text-sm " <> if(@active_section == "indeed", do: "active", else: "")}>
                  Indeed OAuth 2.0
                </a>
              </li>
              <li>
                <a href="#gupy" class={"text-sm " <> if(@active_section == "gupy", do: "active", else: "")}>
                  Gupy SAML 2.0
                </a>
              </li>
              <li>
                <a href="#ai" class={"text-sm " <> if(@active_section == "ai", do: "active", else: "")}>
                  Integração com IA
                </a>
              </li>
              <li>
                <a href="#skills" class={"text-sm " <> if(@active_section == "skills", do: "active", else: "")}>
                  Página de Habilidades
                </a>
              </li>
            </ul>

            <div class="divider"></div>

            <div class="space-y-2">
              <.link navigate="/configuracoes" class="btn btn-sm btn-block btn-ghost justify-start">
                ← Configurações
              </.link>
              <.link navigate="/habilidades" class="btn btn-sm btn-block btn-primary justify-start">
                Habilidades
              </.link>
            </div>
          </div>
        </aside>

        <!-- Main Content -->
        <main class="flex-1 min-w-0">
          <!-- LinkedIn Section -->
          <section id="linkedin" class="bg-base-200 border border-base-300 rounded-lg p-6 mb-6">
            <div class="flex items-center gap-2 mb-4">
              <div class="w-3 h-3 rounded-full bg-success"></div>
              <h2 class="text-xl font-semibold text-base-content">LinkedIn OAuth 2.0</h2>
            </div>

            <div class="alert alert-success mb-4">
              <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              <span><strong>Implementado e Testado</strong> - Fluxo OAuth 2.0 completo</span>
            </div>

            <div class="space-y-4 text-base-content/80">
              <div>
                <h3 class="font-bold mb-2">Como Configurar:</h3>
                <ol class="list-decimal list-inside space-y-2">
                  <li>Acesse <a href="https://www.linkedin.com/developers/apps/new" class="link link-primary" target="_blank">LinkedIn Developers</a></li>
                  <li>Crie um aplicativo e copie o <strong>Client ID</strong> e <strong>Primary Client Secret</strong></li>
                  <li>Adicione a URL de redirecionamento: <code class="bg-base-300 px-2 py-1 rounded text-xs">http://localhost:4000/auth/linkedin/callback</code></li>
                  <li>No AutoVagas, vá em <strong>Configurações → Integrações</strong></li>
                  <li>Clique em "Credenciais" (LinkedIn) e insira os dados</li>
                  <li>Clique em "Conectar" e autorize no navegador</li>
                </ol>
              </div>

              <div class="bg-base-300 p-4 rounded">
                <h4 class="font-bold text-sm mb-2">URLs Importantes:</h4>
                <div class="space-y-1 text-xs">
                  <p><strong>Callback:</strong> <code>http://localhost:4000/auth/linkedin/callback</code></p>
                  <p><strong>API Profile:</strong> <code>https://api.linkedin.com/v2/me</code></p>
                </div>
              </div>

              <div>
                <h4 class="font-bold text-sm mb-2">Estrutura Técnica:</h4>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-2 text-xs">
                  <div class="bg-base-100 p-2 rounded">
                    <strong>Adapter:</strong> <code>lib/auto_vagas/sites/linkedin.ex</code>
                  </div>
                  <div class="bg-base-100 p-2 rounded">
                    <strong>Auth:</strong> <code>lib/auto_vagas/auth/linkedin.ex</code>
                  </div>
                  <div class="bg-base-100 p-2 rounded">
                    <strong>Controller:</strong> <code>lib/auto_vagas_web/controllers/auth_controller.ex</code>
                  </div>
                  <div class="bg-base-100 p-2 rounded">
                    <strong>Criptografia:</strong> AES-256-GCM
                  </div>
                </div>
              </div>
            </div>

            <div class="mt-4">
              <a href="https://learn.microsoft.com/en-us/linkedin/" class="btn btn-primary btn-sm" target="_blank">
                Documentação Oficial →
              </a>
            </div>
          </section>

          <!-- Indeed Section -->
          <section id="indeed" class="bg-base-200 border border-base-300 rounded-lg p-6 mb-6">
            <div class="flex items-center gap-2 mb-4">
              <div class="w-3 h-3 rounded-full bg-warning"></div>
              <h2 class="text-xl font-semibold text-base-content">Indeed OAuth 2.0</h2>
            </div>

            <div class="alert alert-warning mb-4">
              <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
              </svg>
              <span><strong>Em Progresso</strong> - Estrutura criada, aguardando implementação</span>
            </div>

            <div class="space-y-4 text-base-content/80">
              <div>
                <h3 class="font-bold mb-2">Como Configurar:</h3>
                <ol class="list-decimal list-inside space-y-2">
                  <li>Acesse o portal de desenvolvedores Indeed</li>
                  <li>Registre uma aplicação e obtenha as credenciais</li>
                  <li>Configure os escopos necessários para busca de vagas</li>
                  <li>Adicione as credenciais no AutoVagas</li>
                </ol>
              </div>

              <div>
                <h4 class="font-bold text-sm mb-2">Estrutura Técnica:</h4>
                <div class="space-y-1 text-xs">
                  <p><strong>Adapter:</strong> <code>lib/auto_vagas/sites/indeed.ex</code></p>
                  <p><strong>Auth Module:</strong> <code>lib/auto_vagas/auth/indeed.ex</code> (estrutura)</p>
                  <p><strong>Dois Fluxos:</strong> Candidatos vs Empresas</p>
                </div>
              </div>
            </div>
          </section>

          <!-- Gupy Section -->
          <section id="gupy" class="bg-base-200 border border-base-300 rounded-lg p-6 mb-6">
            <div class="flex items-center gap-2 mb-4">
              <div class="w-3 h-3 rounded-full bg-error"></div>
              <h2 class="text-xl font-semibold text-base-content">Gupy SAML 2.0</h2>
            </div>

            <div class="alert alert-error mb-4">
              <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
              </svg>
              <span><strong>Difícil</strong> - Requer SAML 2.0, certificado X.509</span>
            </div>

            <div class="space-y-4 text-base-content/80">
              <div>
                <h3 class="font-bold mb-2">Como Configurar:</h3>
                <ol class="list-decimal list-inside space-y-2">
                  <li>Solicite acesso SSO corporativo ao RH da empresa Gupy</li>
                  <li>Obtenha o certificado X.509 (chave pública/privada)</li>
                  <li>Configure o whitelist de IP/domínio da aplicação</li>
                  <li>Importe o certificado no AutoVagas</li>
                </ol>
              </div>

              <div>
                <h4 class="font-bold text-sm mb-2">Estrutura Técnica:</h4>
                <div class="space-y-1 text-xs">
                  <p><strong>Adapter:</strong> <code>lib/auto_vagas/sites/gupy.ex</code></p>
                  <p><strong>Auth Module:</strong> <code>lib/auto_vagas/auth/gupy.ex</code> (estrutura)</p>
                  <p><strong>Protocolo:</strong> SAML 2.0 (XML, assinaturas)</p>
                  <p><strong>Biblioteca:</strong> Requer <code>samly</code> para SAML</p>
                </div>
              </div>
            </div>
          </section>

          <!-- AI Integration Section -->
          <section id="ai" class="bg-base-200 border border-base-300 rounded-lg p-6 mb-6">
            <div class="flex items-center gap-2 mb-4">
              <div class="w-3 h-3 rounded-full bg-success"></div>
              <h2 class="text-xl font-semibold text-base-content">Integração com IA</h2>
            </div>

            <div class="alert alert-success mb-4">
              <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              <span><strong>Implementado</strong> - Reconhecimento automático com Ollama, Gemini e OpenAI</span>
            </div>

            <div class="space-y-4 text-base-content/80">
              <div>
                <h3 class="font-bold mb-2">Provedores Suportados:</h3>
                <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div class="card bg-base-100 shadow-sm">
                    <div class="card-body p-4">
                      <h4 class="font-bold text-sm">Ollama (Local) ✅</h4>
                      <p class="text-xs">Modelo: llama3.2</p>
                      <p class="text-xs">Endpoint: http://localhost:11434</p>
                      <div class="badge badge-success badge-sm mt-2">Testado</div>
                    </div>
                  </div>
                  <div class="card bg-base-100 shadow-sm">
                    <div class="card-body p-4">
                      <h4 class="font-bold text-sm">Gemini API</h4>
                      <p class="text-xs">Modelo: gemini-2.0-flash</p>
                      <p class="text-xs">Requer: GEMINI_API_KEY</p>
                    </div>
                  </div>
                  <div class="card bg-base-100 shadow-sm">
                    <div class="card-body p-4">
                      <h4 class="font-bold text-sm">OpenAI API</h4>
                      <p class="text-xs">Modelo: gpt-4o-mini</p>
                      <p class="text-xs">Requer: OPENAI_API_KEY</p>
                    </div>
                  </div>
                </div>
              </div>

              <div>
                <h3 class="font-bold mb-2">Funcionalidades:</h3>
                <ul class="list-disc list-inside space-y-1 text-sm">
                  <li><strong>Extração de Experiência:</strong> Analisa currículo e extrai anos por tecnologia</li>
                  <li><strong>Complemento de Perfil:</strong> Atualiza automaticamente user_info.json</li>
                  <li><strong>Processamento PDF:</strong> Extrai texto de currículos</li>
                  <li><strong>Explicações:</strong> IA gera explicações para habilidades</li>
                </ul>
              </div>

              <div>
                <h3 class="font-bold mb-2">Como Usar:</h3>
                <ol class="list-decimal list-inside space-y-2 text-sm">
                  <li>Instale Ollama: <code class="bg-base-300 px-2 py-1 rounded">curl -fsSL https://ollama.com/install.sh | sh</code></li>
                  <li>Inicie: <code class="bg-base-300 px-2 py-1 rounded">ollama serve</code></li>
                  <li>Baixe o modelo: <code class="bg-base-300 px-2 py-1 rounded">ollama pull llama3.2</code></li>
                  <li>Configure <code>priv/ai_config.json</code></li>
                  <li>Teste: <code class="bg-base-300 px-2 py-1 rounded">mix run test_ai.exs</code></li>
                </ol>
              </div>
            </div>
          </section>

          <!-- Skills Page Section -->
          <section id="skills" class="bg-base-200 border border-base-300 rounded-lg p-6 mb-6">
            <div class="flex items-center gap-2 mb-4">
              <div class="w-3 h-3 rounded-full bg-success"></div>
              <h2 class="text-xl font-semibold text-base-content">Página de Habilidades</h2>
            </div>

            <div class="alert alert-success mb-4">
              <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              <span><strong>Implementado</strong> - Visualização completa com explicações de IA</span>
            </div>

            <div class="space-y-4 text-base-content/80">
              <div>
                <h3 class="font-bold mb-2">Abas Disponíveis:</h3>
                <div class="flex flex-wrap gap-2">
                  <div class="badge badge-outline">Técnicas</div>
                  <div class="badge badge-outline">Comportamentais</div>
                  <div class="badge badge-outline">Certificações</div>
                  <div class="badge badge-outline">Cursos</div>
                  <div class="badge badge-outline">Hack The Box</div>
                </div>
              </div>

              <div>
                <h3 class="font-bold mb-2">Funcionalidades:</h3>
                <ul class="list-disc list-inside space-y-1 text-sm">
                  <li><strong>Visualização:</strong> Cards organizados por categoria</li>
                  <li><strong>Explicações:</strong> Geradas por IA (Ollama testado)</li>
                  <li><strong>Toggle:</strong> Mostrar/ocultar explicações</li>
                  <li><strong>Atualização:</strong> Botão "Atualizar c/ IA"</li>
                </ul>
              </div>

              <div>
                <.link navigate="/habilidades" class="btn btn-primary btn-sm">
                  Ver Habilidades →
                </.link>
              </div>
            </div>
          </section>
        </main>
      </div>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, active_page: "ajuda", active_section: "linkedin")}
  end
end
