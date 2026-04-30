defmodule AutoVagas.LLM.OpenAI do
  @moduledoc """
  Integração com OpenAI API (GPT-4o, GPT-3.5, etc.).
  Requer OPENAI_API_KEY configurada no ai_config.json ou ENV.
  """

  require Logger

  @base_url "https://api.openai.com/v1"

  @doc """
  Analisa currículo usando OpenAI API.
  """
  def analyze_resume(resume_text, opts \\ []) do
    api_key = opts[:api_key] || System.get_env("OPENAI_API_KEY")
    model = opts[:model] || "gpt-4o-mini"

    if is_nil(api_key) do
      {:error, "OPENAI_API_KEY not configured"}
    else
      url = "#{@base_url}/chat/completions"

      payload = %{
        "model" => model,
        "messages" => [
          %{
            "role" => "user",
            "content" => build_prompt(resume_text, opts)
          }
        ],
        "response_format" => %{"type" => "json_object"}
      }

      headers = [
        {"Content-Type", "application/json"},
        {"Authorization", "Bearer #{api_key}"}
      ]

      case Req.post(url, json: payload, headers: headers, retry: :transient) do
        {:ok, %Req.Response{status: 200, body: body}} ->
          response = if is_binary(body), do: Jason.decode!(body), else: body
          text = extract_text_from_response(response)
          {:ok, text}

        {:ok, %Req.Response{status: status, body: body}} ->
          Logger.error("OpenAI API error: #{status} - #{inspect(body)}")
          {:error, "OpenAI API error: #{status}"}

        {:error, reason} ->
          Logger.error("OpenAI connection error: #{inspect(reason)}")
          {:error, "Cannot connect to OpenAI: #{inspect(reason)}"}
      end
    end
  end

  defp extract_text_from_response(response) do
    response
    |> get_in(["choices", Access.at(0), "message", "content"])
    |> (fn text -> text || inspect(response) end).()
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
