defmodule AutoVagas.AI do
  @moduledoc """
  Módulo principal para integração com modelos de IA.
  Suporta múltiplos provedores: Ollama (local), Gemini, OpenAI, etc.
  """

  @doc """
  Configuração padrão de IA.
  """
  def config do
    %{
      provider: get_provider(),
      ollama: %{
        enabled: get_in_config(load_ai_config(), [:ollama, :enabled]) || false,
        endpoint: get_in_config(load_ai_config(), [:ollama, :endpoint]) || "http://localhost:11434",
        model: get_in_config(load_ai_config(), [:ollama, :model]) || "llama3.2"
      },
      gemini: %{
        enabled: get_in_config(load_ai_config(), [:gemini, :enabled]) || false,
        api_key: get_in_config(load_ai_config(), [:gemini, :api_key]) || System.get_env("GEMINI_API_KEY"),
        model: get_in_config(load_ai_config(), [:gemini, :model]) || "gemini-2.0-flash"
      },
      openai: %{
        enabled: get_in_config(load_ai_config(), [:openai, :enabled]) || false,
        api_key: get_in_config(load_ai_config(), [:openai, :api_key]) || System.get_env("OPENAI_API_KEY"),
        model: get_in_config(load_ai_config(), [:openai, :model]) || "gpt-4o-mini"
      }
    }
  end

  @doc """
  Analisa um currículo e extrai informações estruturadas.
  """
  def analyze_resume(resume_text, opts \\ []) do
    provider = opts[:provider] || get_provider()
    
    case provider do
      :ollama -> AutoVagas.AI.Ollama.analyze_resume(resume_text, opts)
      :gemini -> AutoVagas.AI.Gemini.analyze_resume(resume_text, opts)
      :openai -> AutoVagas.AI.OpenAI.analyze_resume(resume_text, opts)
      _ -> {:error, "Provedor de IA não suportado: #{provider}"}
    end
  end

  @doc """
  Extrai informações de experiência profissional do currículo.
  """
  def extract_experience(resume_text, opts \\ []) do
    _prompt = """
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

    case analyze_resume(resume_text, opts) do
      {:ok, result} -> parse_experience_json(result)
      error -> error
    end
  end

  @doc """
  Completa informações faltantes no user_info baseado no currículo.
  """
  def complete_user_info(resume_text, user_info \\ %{}, opts \\ []) do
    _prompt = """
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

    case analyze_resume(resume_text, opts) do
      {:ok, result} -> parse_user_info_json(result, user_info)
      error -> error
    end
  end

  defp parse_experience_json(json_str) do
    case Jason.decode(json_str) do
      {:ok, %{"experience" => exp}} -> {:ok, exp}
      {:ok, other} -> {:error, "Formato inválido: #{inspect(other)}"}
      {:error, _} -> 
        # Tenta extrair JSON se houver texto antes/depois
        case Regex.run(~r/\{.*\}/s, json_str) do
          [match] -> parse_experience_json(match)
          nil -> {:error, "Não foi possível parsear resposta da IA"}
        end
    end
  end

  defp parse_user_info_json(json_str, current_info) do
    case Jason.decode(json_str) do
      {:ok, new_info} -> 
        merged = merge_user_info(current_info, new_info)
        {:ok, merged}
      {:error, _} -> 
        case Regex.run(~r/\{.*\}/s, json_str) do
          [match] -> parse_user_info_json(match, current_info)
          nil -> {:error, "Não foi possível parsear resposta da IA"}
        end
    end
  end

  defp merge_user_info(current, new) do
    current
    |> Map.merge(new)
    |> Map.update(:experience, %{}, fn _exp -> 
      Map.merge(Map.get(current, :experience, %{}), Map.get(new, "experience", %{}))
    end)
  end

  defp get_provider do
    config = load_ai_config()
    cond do
      Map.get(config, :gemini) && Map.get(config.gemini, :enabled) -> :gemini
      Map.get(config, :ollama) && Map.get(config.ollama, :enabled) -> :ollama
      Map.get(config, :openai) && Map.get(config.openai, :enabled) -> :openai
      true -> :ollama
    end
  end

  defp load_ai_config do
    path = "priv/ai_config.json"
    if File.exists?(path) do
      path |> File.read!() |> Jason.decode!(keys: :atoms)
    else
      %{}
    end
  end

  defp get_in_config(map, keys) do
    keys
    |> Enum.reduce(map, fn key, acc -> 
      if is_map(acc), do: Map.get(acc, key), else: nil
    end)
  end
end
