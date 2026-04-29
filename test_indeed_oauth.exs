# Test script for Indeed OAuth 2.0
# Usage: mix run test_indeed_oauth.exs

alias AutoVagas.Auth.Indeed

IO.puts("=== Teste Indeed OAuth 2.0 ===\n")

# Step 1: Generate authorization URL
IO.puts("1. Gerando URL de autorização...")
auth_url = Indeed.authorize_url("test_state_123")
IO.puts("URL: #{auth_url}\n")

# Step 2: Check if client_id is configured
IO.puts("2. Verificando configurações...")
config_path = "priv/filters/auth_config.json"

if File.exists?(config_path) do
  config = File.read!(config_path) |> Jason.decode!()
  indeed_config = get_in(config, ["indeed"])

  if indeed_config do
    IO.puts("Indeed configurado:")
    IO.puts("  Client ID: #{get_in(indeed_config, ["client_id"])}")
    IO.puts("  Client Secret: #{if get_in(indeed_config, ["client_secret"]), do: "***ENCRYPTED***", else: "NAO CONFIGURADO"}")
  else
    IO.puts("Indeed NAO configurado em auth_config.json")
    IO.puts("Adicione via /configuracoes ou edite priv/filters/auth_config.json")
  end
else
  IO.puts("Arquivo auth_config.json nao existe ainda.")
  IO.puts("Configure via /configuracoes primeiro.")
end

IO.puts("\n3. Instruções para teste no navegador:")
IO.puts("   a) Acesse a URL de autorização acima")
IO.puts("   b) Faça login no Indeed e autorize o app")
IO.puts("   c) Indeed redirecionará para: http://localhost:4000/auth/indeed/callback?code=...&state=...")
IO.puts("   d) O sistema trocará o código por access_token automaticamente")
IO.puts("   e) Você será redirecionado para /configuracoes com mensagem de sucesso")

IO.puts("\n=== URLs Importantes ===")
IO.puts("Authorization URL: #{auth_url}")
IO.puts("Callback URL: http://localhost:4000/auth/indeed/callback")
IO.puts("Configurações: http://localhost:4000/configuracoes")

IO.puts("\n=== Como configurar Indeed OAuth ===")
IO.puts("1. Acesse: https://developer.indeed.com/")
IO.puts("2. Crie uma conta de desenvolvedor")
IO.puts("3. Crie um aplicativo")
IO.puts("4. Copie Client ID e Client Secret")
IO.puts("5. Adicione Redirect URI: http://localhost:4000/auth/indeed/callback")
IO.puts("6. No AutoVagas, vá em /configuracoes → Indeed → Adicionar Credenciais")
IO.puts("7. Salve (client_secret será criptografado com AES-256)")

IO.puts("\n=== Teste concluído ===")
