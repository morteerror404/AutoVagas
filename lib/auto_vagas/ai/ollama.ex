defmodule AutoVagas.AI.Ollama do
  @moduledoc """
  Integração com Ollama (IA local).
  Requer Ollama rodando em http://localhost:11434.
  """

  require Logger

  @doc """
  Analisa currículo usando Ollama.
  """
  def analyze_resume(resume_text, opts \\ []) do
    model = opts[:model] || "llama3.2"
    endpoint = opts[:endpoint] || "http://localhost:11434"

    payload = %{
      "model" => model,
      "prompt" => build_prompt(resume_text, opts),
      "stream" => false,
      "format" => "json"
    }

    headers = [{"Content-Type", "application/json"}]

    case Req.post("#{endpoint}/api/generate", 
          json: payload, 
          headers: headers,
          retry: :transient) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        response = if is_binary(body), do: Jason.decode!(body), else: body
        text = Map.get(response, "response", "")
        {:ok, text}

      {:ok, %Req.Response{status: status, body: body}} ->
        Logger.error("Ollama request failed: #{status} - #{inspect(body)}")
        {:error, "Ollama request failed: #{status}"}

      {:error, reason} ->
        Logger.error("Ollama connection error: #{inspect(reason)}")
        {:error, "Cannot connect to Ollama: #{inspect(reason)}"}
    end
  end

  defp build_prompt(resume_text, opts) do
    task = opts[:task] || "analyze_resume"
    
    case task do
      "analyze_resume" ->
        """
        Analise o currículo abaixo e extraia as informações de experiência profissional.
        Retorne um JSON com a seguinte estrutura:
        {
          "experience": [
            {
              "technology": "nome da tecnologia (ex: Python, Java, Elixir)",
              "initial_year_experience": ano_inicial,
              "years_calculated": anos_totais_calculados
            }
          ]
        }

        Currículo:
        #{resume_text}

        Responda APENAS o JSON, sem texto adicional.
        """

      "complete_user_info" ->
        user_info = opts[:user_info] || %{}
        """
        Analise o currículo abaixo e complete as informações para o perfil do usuário.
        Retorne um JSON com a seguinte estrutura:
        {
          "location": "cidade/país",
          "languages": ["idioma1", "idioma2"],
          "experience": {
            "tecnologia1": {"initial_year_experience": ano, "years_calculated": anos},
            "tecnologia2": {"initial_year_experience": ano, "years_calculated": anos}
          }
        }

        Currículo:
        #{resume_text}

        Informações atuais (manter o que já existe e completar o que falta):
        #{Jason.encode!(user_info, pretty: true)}

        Responda APENAS o JSON, sem texto adicional.
        """

      _ ->
        opts[:prompt] || "Analise o seguinte currículo: #{resume_text}"
    end
  end
end
