defmodule AutoVagas.Automation.AutoComplete do
  @moduledoc """
  Sistema de auto-complete via LLM (Ollama) para coletar informações do usuário.
  """

  @user_info_path "priv/user_info.json"

  @doc """
  Processa uma pergunta e verifica se precisa de dados do usuário.
  Retorna {:ok, answer} se já possui, {:need_info, question} se precisa perguntar.
  """
  @spec process_question(String.t()) :: {:ok, any()} | {:need_info, String.t(), String.t()}
  def process_question(question) do
    case detect_needed_field(question) do
      nil ->
        {:ok, nil}

      field ->
        user_info = load_user_info()
        field_key = field_name(field)
        field_value = user_info["experience"][field_key]

        cond do
          is_list(field_value) and field_value == [] ->
            {:need_info, question, field}

          field_value != [] and field_value != nil ->
            {:ok, format_answer(field, field_value)}

          true ->
            {:ok, nil}
        end
    end
  end

  @doc """
  Salva uma resposta de experiência no user_info.json.
  """
  @spec save_experience(String.t(), String.t(), String.t()) :: :ok
  def save_experience(field, key, _value) do
    user_info = load_user_info()

    updated =
      update_in(user_info, ["experience", field_name(field)], fn current ->
        Enum.find_index(current, &(&1 == key))
        |> case do
          nil -> current ++ [key]
          _ -> current
        end
      end)

    save_user_info(updated)
  end

  @doc """
  Verifica se uma pergunta já foi respondida.
  """
  @spec already_answered?(String.t(), String.t()) :: boolean()
  def already_answered?(field, key) do
    user_info = load_user_info()
    current = user_info["experience"][field_name(field)]
    key in current
  end

  @doc """
  Detecta o campo necessário para uma pergunta usando Ollama.
  """
  @spec detect_needed_field(String.t()) :: String.t() | nil
  def detect_needed_field(question) do
    AutoVagas.LLM.Ollama.classify_question(question)
  end

  defp field_name("job_roles"), do: "job_roles"
  defp field_name("resources"), do: "resources"
  defp field_name(field) when is_binary(field), do: field

  @doc """
  Busca um campo de experiência no user_info.
  """
  def fetch_field(user_info, field) do
    user_info["experience"][field_name(field)]
  end

  defp format_answer(_field, value) when is_list(value) do
    Enum.join(value, ", ")
  end

  defp load_user_info do
    @user_info_path
    |> File.read!()
    |> Jason.decode!()
  rescue
    _ -> %{experience: %{job_roles: [], resources: []}}
  end

  defp save_user_info(info) do
    encoded = Jason.encode!(info, pretty: true)
    File.write!(@user_info_path, encoded)
  end
end

defmodule AutoVagas.AutoComplete.Ollama do
  @moduledoc """
  Integração com Ollama para detecção de campos.
  """

  @prompt """
  Você é um classificador de perguntas. Given uma pergunta sobre vagas de emprego,
  detecte qual campo de informação do usuário é necessário para responder.

  Campos disponíveis:
  - job_roles: funções/papéis profissionais (ex: "desenvolvedor", "analista", "gerente")
  - resources: tecnologias/ferramentas (ex: "elixir", "python", "react")

  Responda apenas com o nome do campo (job_roles ou resources) ou "none" se não for sobre esses campos.

  Pergunta:
  """

  @spec classify_question(String.t()) :: String.t() | nil
  def classify_question(question) do
    full_prompt = @prompt <> question <> "\nResposta:"

    case Req.post!("http://localhost:11434/api/generate",
           json: %{
             model: "llama3.2",
             prompt: full_prompt,
             stream: false
           }
         ) do
      %{status: 200, body: %{"response" => response}} ->
        parse_response(response)

      _ ->
        nil
    end
  end

  defp parse_response(response) do
    response
    |> String.downcase()
    |> String.trim()
    |> case do
      "job_roles" -> "job_roles"
      "resources" -> "resources"
      _ -> nil
    end
  end
end
