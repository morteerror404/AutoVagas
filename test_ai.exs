defmodule AutoVagas.AITest do
  @moduledoc """
  Script para testar a integração com IA (Ollama, Gemini, OpenAI).
  Execute: mix run test_ai.exs
  """

  def run do
    IO.puts("=== Teste de Integração com IA ===")

    # Verifica configuração
    config = AutoVagas.AI.config()
    IO.inspect(config, label: "Configuração de IA")

    # Exemplo de currículo (simulado)
    resume = """
    João Silva
    Desenvolvedor de Software

    Experiência:
    - Python (2018 - Atual): 8 anos de experiência
    - Elixir (2020 - Atual): 6 anos de experiência
    - Docker (2021 - Atual): 5 anos de experiência

    Localização: São Paulo, Brasil
    Idiomas: Português (Nativo), Inglês (Fluente), Espanhol (Básico)
    """

    # Teste 1: Extrair experiência
    IO.puts("\n--- Teste 1: Extrair experiência ---")
    case AutoVagas.AI.extract_experience(resume) do
      {:ok, exp} ->
        IO.puts("Sucesso! Experiência extraída:")
        IO.inspect(exp, pretty: true)

      {:error, reason} ->
        IO.puts("Erro: #{inspect(reason)}")
    end

    # Teste 2: Completar user_info
    IO.puts("\n--- Teste 2: Completar user_info ---")
    current_info = %{
      "location" => "Brazil",
      "languages" => ["Portuguese"],
      "experience" => %{
        "python" => %{"initial_year_experience" => 2018}
      }
    }

    case AutoVagas.AI.complete_user_info(resume, current_info) do
      {:ok, info} ->
        IO.puts("Sucesso! user_info atualizado:")
        IO.inspect(info, pretty: true)

      {:error, reason} ->
        IO.puts("Erro: #{inspect(reason)}")
    end

    # Teste 3: Verificar provedores disponíveis
    IO.puts("\n--- Teste 3: Provedores disponíveis ---")
    check_providers()
  end

  defp check_providers do
    # Ollama
    case HTTPoison.get("http://localhost:11434") do
      {:ok, %HTTPoison.Response{status: 200}} ->
        IO.puts("✓ Ollama está rodando em http://localhost:11434")

      _ ->
        IO.puts("✗ Ollama não está rodando. Inicie com: ollama serve")
    end

    # Gemini API
    if System.get_env("GEMINI_API_KEY") do
      IO.puts("✓ GEMINI_API_KEY configurada")
    else
      IO.puts("✗ GEMINI_API_KEY não configurada. Configure no priv/ai_config.json ou ENV")
    end

    # OpenAI API
    if System.get_env("OPENAI_API_KEY") do
      IO.puts("✓ OPENAI_API_KEY configurada")
    else
      IO.puts("✗ OPENAI_API_KEY não configurada. Configure no priv/ai_config.json ou ENV")
    end
  end
end

# Executa os testes
AutoVagas.AITest.run()
