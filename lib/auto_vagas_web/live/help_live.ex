defmodule AutoVagasWeb.HelpLive do
  use AutoVagasWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto p-6">
      <h1 class="text-3xl font-bold text-base-content mb-6">Ajuda - Integrações SSO e Plataformas</h1>
      
      <!-- LinkedIn Section -->
      <section class="bg-base-200 border border-base-300 rounded-lg p-6 mb-6">
        <h2 class="text-xl font-semibold text-base-content mb-4">LinkedIn OAuth 2.0</h2>
        <div class="space-y-4 text-base-content/80">
          <div class="alert alert-info">
            <p class="font-bold">✅ Implementado e Testado</p>
            <p class="text-sm">Fluxo OAuth 2.0 completo com troca automática de código por token.</p>
          </div>
          
          <h3 class="font-bold">Como Configurar:</h3>
          <ol class="list-decimal list-inside space-y-2">
            <li>Acesse <a href="https://www.linkedin.com/developers/apps/new" class="link link-primary" target="_blank">LinkedIn Developers</a></li>
            <li>Crie um aplicativo e copie o <strong>Client ID</strong> e <strong>Primary Client Secret</strong></li>
            <li>Adicione a URL de redirecionamento: <code class="bg-base-300 px-2 py-1 rounded">http://localhost:4000/auth/linkedin/callback</code></li>
            <li>No AutoVagas, vá em <.link navigate="/configuracoes" class="link link-primary">Configurações</.link></li>
            <li>Clique em "Adicionar Credenciais" (LinkedIn) e insira os dados</li>
            <li>Clique em "Integrar" e autorize no navegador</li>
          </ol>

          <h3 class="font-bold mt-4">URLs Importantes:</h3>
          <div class="bg-base-300 p-4 rounded space-y-2">
            <p><strong>URL de Autorização:</strong></p>
            <code class="text-sm break-all">https://www.linkedin.com/oauth/v2/authorization?scope=r_liteprofile+r_emailaddress&client_id=77ye1svdvforpt&redirect_uri=http%3A%2F%2Flocalhost%3A4000%2Fauth%2Flinkedin%2Fcallback&response_type=code</code>
            
            <p><strong>Callback:</strong> <code>http://localhost:4000/auth/linkedin/callback</code></p>
            <p><strong>API Profile:</strong> <code>https://api.linkedin.com/v2/me</code></p>
          </div>

          <h3 class="font-bold mt-4">Estrutura Técnica:</h3>
          <ul class="list-disc list-inside space-y-1 text-sm">
            <li><strong>Adapter:</strong> <code>lib/auto_vagas/sites/linkedin.ex</code></li>
            <li><strong>Auth Module:</strong> <code>lib/auto_vagas/auth/linkedin.ex</code></li>
            <li><strong>Controller:</strong> <code>lib/auto_vagas_web/controllers/auth_controller.ex</code></li>
            <li><strong>Criptografia:</strong> AES-256-GCM para client_secret</li>
            <li><strong>Scopes:</strong> r_liteprofile, r_emailaddress</li>
          </ul>
        </div>
        <div class="mt-4">
          <a href="https://learn.microsoft.com/en-us/linkedin/" class="btn btn-primary btn-sm" target="_blank">Documentação Oficial</a>
        </div>
      </section>

      <!-- Indeed Section -->
      <section class="bg-base-200 border border-base-300 rounded-lg p-6 mb-6">
        <h2 class="text-xl font-semibold text-base-content mb-4">Indeed OAuth 2.0</h2>
        <div class="space-y-4 text-base-content/80">
          <div class="alert alert-warning">
            <p class="font-bold">🚧 Em Progresso</p>
            <p class="text-sm">Estrutura criada, aguardando implementação completa do fluxo.</p>
          </div>
          
          <h3 class="font-bold">Como Configurar:</h3>
          <ol class="list-decimal list-inside space-y-2">
            <li>Acesse o portal de desenvolvedores Indeed</li>
            <li>Registre uma aplicação e obtenha as credenciais</li>
            <li>Configure os escopos necessários para busca de vagas</li>
            <li>Adicione as credenciais no AutoVagas</li>
          </ol>

          <h3 class="font-bold mt-4">Estrutura Técnica:</h3>
          <ul class="list-disc list-inside space-y-1 text-sm">
            <li><strong>Adapter:</strong> <code>lib/auto_vagas/sites/indeed.ex</code></li>
            <li><strong>Auth Module:</strong> <code>lib/auto_vagas/auth/indeed.ex</code> (estrutura)</li>
            <li><strong>Dois Fluxos:</strong> Candidatos vs Empresas</li>
            <li><strong>Documentação:</strong> Limitada para integração via SSO</li>
          </ul>
        </div>
      </section>

      <!-- Gupy Section -->
      <section class="bg-base-200 border border-base-300 rounded-lg p-6 mb-6">
        <h2 class="text-xl font-semibold text-base-content mb-4">Gupy SAML 2.0</h2>
        <div class="space-y-4 text-base-content/80">
          <div class="alert alert-warning">
            <p class="font-bold">🚧 Difícil - Requer SAML 2.0</p>
            <p class="text-sm">SAML 2.0 é complexo (XML, assinaturas digitais). Requer biblioteca <code>samly</code>.</p>
          </div>
          
          <h3 class="font-bold">Como Configurar:</h3>
          <ol class="list-decimal list-inside space-y-2">
            <li>Solicite acesso SSO corporativo ao RH da empresa Gupy</li>
            <li>Obtenha o certificado X.509 (chave pública/privada)</li>
            <li>Configure o whitelist de IP/domínio da aplicação</li>
            <li>Importe o certificado no AutoVagas</li>
          </ol>

          <h3 class="font-bold mt-4">Estrutura Técnica:</h3>
          <ul class="list-disc list-inside space-y-1 text-sm">
            <li><strong>Adapter:</strong> <code>lib/auto_vagas/sites/gupy.ex</code> (API)</li>
            <li><strong>Auth Module:</strong> <code>lib/auto_vagas/auth/gupy.ex</code> (estrutura)</li>
            <li><strong>Protocolo:</strong> SAML 2.0 (XML, assinaturas)</li>
            <li><strong>Biblioteca:</strong> Requer <code>samly</code> para SAML</li>
            <li><strong>Certificado:</strong> X.509 necessário</li>
          </ul>
        </div>
      </section>

      <!-- AI Integration Section -->
      <section class="bg-base-200 border border-base-300 rounded-lg p-6 mb-6">
        <h2 class="text-xl font-semibold text-base-content mb-4">Integração com IA ✅</h2>
        <div class="space-y-4 text-base-content/80">
          <div class="alert alert-success">
            <p class="font-bold">✅ Implementado e Funcionando</p>
            <p class="text-sm">Reconhecimento automático de currículo com Ollama, Gemini e OpenAI.</p>
          </div>
          
          <h3 class="font-bold">Provedores Suportados:</h3>
          <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div class="card bg-base-100 shadow-sm">
              <div class="card-body p-4">
                <h4 class="font-bold">Ollama (Local) ✅</h4>
                <p class="text-sm">Modelo: llama3.2</p>
                <p class="text-sm">Endpoint: http://localhost:11434</p>
                <p class="text-sm">Status: Testado e funcionando</p>
              </div>
            </div>
            <div class="card bg-base-100 shadow-sm">
              <div class="card-body p-4">
                <h4 class="font-bold">Gemini API</h4>
                <p class="text-sm">Modelo: gemini-2.0-flash</p>
                <p class="text-sm">Requer: GEMINI_API_KEY</p>
                <p class="text-sm">Status: Implementado</p>
              </div>
            </div>
            <div class="card bg-base-100 shadow-sm">
              <div class="card-body p-4">
                <h4 class="font-bold">OpenAI API</h4>
                <p class="text-sm">Modelo: gpt-4o-mini</p>
                <p class="text-sm">Requer: OPENAI_API_KEY</p>
                <p class="text-sm">Status: Implementado</p>
              </div>
            </div>
          </div>

          <h3 class="font-bold mt-4">Funcionalidades:</h3>
          <ul class="list-disc list-inside space-y-1 text-sm">
            <li><strong>Extração de Experiência:</strong> Analisa currículo e extrai anos por tecnologia</li>
            <li><strong>Complemento de Perfil:</strong> Atualiza automaticamente user_info.json</li>
            <li><strong>Processamento PDF:</strong> Extrai texto de currículos em PDF</li>
            <li><strong>Perfil LinkedIn:</strong> Extrai dados do perfil LinkedIn</li>
            <li><strong>Explicações:</strong> IA gera explicações para habilidades</li>
          </ul>

          <h3 class="font-bold mt-4">Estrutura Técnica:</h3>
          <ul class="list-disc list-inside space-y-1 text-sm">
            <li><strong>Principal:</strong> <code>lib/auto_vagas/ai.ex</code></li>
            <li><strong>Ollama:</strong> <code>lib/auto_vagas/ai/ollama.ex</code></li>
            <li><strong>Gemini:</strong> <code>lib/auto_vagas/ai/gemini.ex</code></li>
            <li><strong>OpenAI:</strong> <code>lib/auto_vagas/ai/openai.ex</code></li>
            <li><strong>PDF:</strong> <code>lib/auto_vagas/ai/pdf.ex</code></li>
            <li><strong>Explicações:</strong> <code>lib/auto_vagas/ai/explanation.ex</code></li>
          </ul>

          <h3 class="font-bold mt-4">Como Usar:</h3>
          <ol class="list-decimal list-inside space-y-2">
            <li>Instale Ollama: <code>curl -fsSL https://ollama.com/install.sh | sh</code></li>
            <li>Inicie: <code>ollama serve</code></li>
            <li>Baixe o modelo: <code>ollama pull llama3.2</code></li>
            <li>Configure <code>priv/ai_config.json</code> (veja example)</li>
            <li>Teste: <code>mix run test_ai.exs</code></li>
          </ol>
        </div>
        <div class="mt-4">
          <a href="https://ollama.com/" class="btn btn-primary btn-sm" target="_blank">Ollama Docs</a>
          <a href="https://ai.google.dev/" class="btn btn-outline btn-sm ml-2" target="_blank">Gemini API</a>
        </div>
      </section>

      <!-- Skills Page Section -->
      <section class="bg-base-200 border border-base-300 rounded-lg p-6 mb-6">
        <h2 class="text-xl font-semibold text-base-content mb-4">Página de Habilidades ✅</h2>
        <div class="space-y-4 text-base-content/80">
          <div class="alert alert-success">
            <p class="font-bold">✅ Implementado e Funcionando</p>
            <p class="text-sm">Visualização completa de habilidades com abas e explicações geradas por IA.</p>
          </div>
          
          <h3 class="font-bold">Abas Disponíveis:</h3>
          <ul class="list-disc list-inside space-y-1">
            <li><strong>Técnicas:</strong> Habilidades técnicas com nível e anos de experiência</li>
            <li><strong>Comportamentais:</strong> Soft skills com nível</li>
            <li><strong>Certificações:</strong> Certificados com emissor e ano</li>
            <li><strong>Cursos:</strong> Cursos realizados com plataforma</li>
            <li><strong>Hack The Box:</strong> Desafios de segurança com explicações</li>
          </ul>

          <h3 class="font-bold mt-4">Funcionalidades:</h3>
          <ul class="list-disc list-inside space-y-1 text-sm">
            <li><strong>Visualização:</strong> Cards organizados por categoria</li>
            <li><strong>Explicações:</strong> Geradas por IA (Ollama testado)</li>
            <li><strong>Toggle:</strong> Mostrar/ocultar explicações</li>
            <li><strong>Atualização:</strong> Botão "Atualizar c/ IA"</li>
          </ul>

          <h3 class="font-bold mt-4">Estrutura Técnica:</h3>
          <ul class="list-disc list-inside space-y-1 text-sm">
            <li><strong>LiveView:</strong> <code>lib/auto_vagas_web/live/skills_live.ex</code></li>
            <li><strong>URL:</strong> <code>http://localhost:4000/habilidades</code></li>
            <li><strong>IA Module:</strong> <code>lib/auto_vagas/ai/explanation.ex</code></li>
          </ul>
        </div>
      </section>

      <div class="mt-6">
        <.link href="/configuracoes" class="btn btn-outline btn-primary">Voltar para Configurações</.link>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
