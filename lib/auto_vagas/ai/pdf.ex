defmodule AutoVagas.AI.PDF do
  @moduledoc """
  Processamento de currículos em PDF.
  Extrai texto de PDFs para análise de IA.
  Requer poppler-utils instalado (pdftotext).
  """

  @doc """
  Extrai texto de um arquivo PDF.
  Retorna {:ok, text} ou {:error, reason}.
  """
  def extract_text(pdf_path) when is_binary(pdf_path) do
    if File.exists?(pdf_path) do
      case System.cmd("pdftotext", [pdf_path, "-"]) do
        {text, 0} -> {:ok, text}
        {error, _code} -> {:error, "Falha ao extrair texto: #{error}"}
      end
    else
      {:error, "Arquivo não encontrado: #{pdf_path}"}
    end
  end

  @doc """
  Salva conteúdo de um upload temporário e extrai texto.
  Aceita tanto texto quanto PDF.
  """
  def process_upload(%{"content_type" => "application/pdf", "path" => path}) do
    extract_text(path)
  end

  def process_upload(%{"content_type" => _, "content" => content}) do
    {:ok, content}
  end

  def process_upload(_), do: {:error, "Formato não suportado"}
end
