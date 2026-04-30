#!/usr/bin/env elixir

# Teste da API LinkedIn
# Execute: mix run test_linkedin_api.exs

require Logger

defmodule LinkedInAPITest do
  @linkedin_auth "priv/filters/auth_config.json"
    |> File.read!()
    |> Jason.decode!()
    |> Map.get("linkedin")

  def run do
    IO.puts("=== Teste da API LinkedIn ===\n")

    # Teste 1: Verificar credenciais
    IO.puts("1. Verificando credenciais...")
    client_id = @linkedin_auth["client_id"]
    client_secret = @linkedin_auth["client_secret"]

    if client_id == "" or client_secret == "" do
      IO.puts("   ERRO: Client ID ou Client Secret nao configurados")
      IO.puts("   Configure em: /configuracoes (botao 'Adicionar Credenciais')")
      System.halt(1)
    else
      IO.puts("   OK: Credenciais encontradas")
      IO.puts("   Client ID: #{String.slice(client_id, 0, 8)}...")
    end

    # Teste 2: Gerar URL de autorizacao
    IO.puts("\n2. Gerando URL de autorizacao...")
    auth_url = AutoVagas.Auth.LinkedIn.authorize_url()
    IO.puts("   URL: #{auth_url}")
    IO.puts("   VISITE A URL ACIMA NO NAVEGADOR PARA AUTORIZAR")

    # Teste 3: Aguardar codigo de autorizacao
    IO.puts("\n3. Aguardando codigo de autorizacao...")
    IO.puts("   Cole o codigo retornado ou pressione Enter para pular:")
    code = IO.gets("   Codigo: ") |> String.trim()

    if code != "" do
      # Teste 4: Trocar codigo por token
      IO.puts("\n4. Trocando codigo por access_token...")
      case AutoVagas.Auth.LinkedIn.exchange_code(code) do
        {:ok, token} ->
          IO.puts("   SUCESSO: Token obtido")
          IO.puts("   Access Token: #{String.slice(token, 0, 20)}...")

          # Teste 5: Testar API (perfil)
          IO.puts("\n5. Testando API - Perfil do Usuario...")
          test_profile_api(token)

        {:error, reason} ->
          IO.puts("   ERRO: #{inspect(reason)}")
      end
    else
      IO.puts("   PULADO: Codigo nao fornecido")
    end

    IO.puts("\n=== Fim dos Testes ===")
  end

  defp test_profile_api(token) do
    headers = [{"Authorization", "Bearer #{token}"}]

    case Req.get("https://api.linkedin.com/v2/me", headers: headers) do
      %{status: 200, body: body} ->
        IO.puts("   SUCESSO: Perfil obtido")
        IO.puts("   Resposta: #{inspect(body)}")

      %{status: status, body: body} ->
        IO.puts("   ERRO: Status #{status}")
        IO.puts("   Resposta: #{inspect(body)}")

      {:error, reason} ->
        IO.puts("   ERRO: #{inspect(reason)}")
    end
  end
end

LinkedInAPITest.run()
