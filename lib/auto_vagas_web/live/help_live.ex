defmodule AutoVagasWeb.HelpLive do
  use AutoVagasWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto p-6">
      <h1 class="text-3xl font-bold text-base-content mb-6">Ajuda - Integracoes SSO</h1>

      <section class="bg-base-200 border border-base-300 rounded-lg p-6 mb-6">
        <h2 class="text-xl font-semibold text-base-content mb-4">LinkedIn OAuth 2.0</h2>
        <ol class="list-decimal list-inside space-y-2 text-base-content/80">
          <li>Acesse <a href="https://www.linkedin.com/developers/apps/new" class="link link-primary" target="_blank">https://www.linkedin.com/developers/apps/new</a></li>
          <li>Crie um aplicativo com nome e descricao</li>
          <li>Vá para "Auth" e copie o <strong>Client ID</strong> e <strong>Primary Client Secret</strong></li>
          <li>Adicione a URL de redirecionamento (Exemplo): <code class="bg-base-300 px-2 py-1 rounded">http://localhost:4000/auth/linkedin/callback</code> para funcionar "de verdade", voce pode conectar a um socket no ngrok para que a aplicação seja funcional atraves da rede.</li>
          <li>No AutoVagas, clique em "Adicionar Credenciais" e insira os dados</li>
          <li>Clique em "Integrar" para conectar sua conta LinkedIn</li>
        </ol>
        <div class="mt-4">
          <a href="https://www.linkedin.com/developers/tools/oauth" class="btn btn-primary btn-sm" target="_blank">Documentacao Oficial</a>
        </div>
      </section>

      <section class="bg-base-200 border border-base-300 rounded-lg p-6 mb-6">
        <h2 class="text-xl font-semibold text-base-content mb-4">Indeed OAuth 2.0</h2>
        <ol class="list-decimal list-inside space-y-2 text-base-content/80">
          <li>Acesse o portal de desenvolvedores do Indeed</li>
          <li>Registre uma aplicacao e obtenha as credenciais</li>
          <li>Configure os escopos necessarios para busca de vagas</li>
          <li>Adicione as credenciais no AutoVagas</li>
        </ol>
      </section>

      <section class="bg-base-200 border border-base-300 rounded-lg p-6 mb-6">
        <h2 class="text-xl font-semibold text-base-content mb-4">Gupy SAML 2.0</h2>
        <ol class="list-decimal list-inside space-y-2 text-base-content/80">
          <li>Solicite acesso SSO corporativo ao RH da empresa</li>
          <li>Obtenha o certificado X.509 (chave publica/privada)</li>
          <li>Configure o whitelist de IP/dominio no portal Gupy</li>
          <li>Importe o certificado no AutoVagas</li>
        </ol>
      </section>

      <div class="mt-6">
        <.link href="/configuracoes" class="btn btn-outline btn-primary">Voltar para Configuracoes</.link>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
