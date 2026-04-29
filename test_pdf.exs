defmodule AutoVagas.AI.PDFTest do
  @moduledoc """
  Testa extração de texto de PDF.
  Execute: mix run test_pdf.exs
  """

  def run do
    IO.puts("=== Teste de Extração PDF ===")

    # Cria um arquivo de teste (simulado)
    test_text = """
    João Silva
    Desenvolvedor de Software

    Experiência:
    - Python (2018 - Atual): 8 anos
    - Elixir (2020 - Atual): 6 anos
    - Docker (2021 - Atual): 5 anos

    Localização: São Paulo, Brasil
    Idiomas: Português (Nativo), Inglês (Fluente)
    """

    # Testa extração de experiência
    IO.puts("\n--- Teste: Extrair Experiência ---")
    case AutoVagas.AI.extract_experience(test_text) do
      {:ok, exp} ->
        IO.puts("Sucesso! Experiência extraída:")
        IO.inspect(exp, pretty: true)

      {:error, reason} ->
        IO.puts("Erro: #{inspect(reason)}")
    end

    # Testa atualização de user_info
    IO.puts("\n--- Teste: Atualizar user_info ---")
    current_info = %{
      "location" => "Brazil",
      "languages" => ["Portuguese"],
      "experience" => %{
        "python" => %{"initial_year_experience" => 2018}
      }
    }

    case AutoVagas.AI.complete_user_info(test_text, current_info) do
      {:ok, info} ->
        IO.puts("Sucesso! user_info atualizado:")
        IO.inspect(info, pretty: true)

      {:error, reason} ->
        IO.puts("Erro: #{inspect(reason)}")
    end

    IO.puts("\n=== Testes concluídos ===")
  end
end

AutoVagas.AI.PDFTest.run()
