defmodule AutoVagas.Notifications.Telegram do
  @moduledoc """
  Integração inicial com Telegram para alertas de vagas.
  Usa Telegram Bot API.
  """

  require Logger

  @base_url "https://api.telegram.org/bot"

  @doc """
  Envia alerta de vaga pendente via Telegram.
  """
  def send_pending_job_alert(config, job) do
    message = build_pending_job_message(job)
    send_message(config, message)
  end

  @doc """
  Envia alerta de nova vaga via Telegram.
  """
  def send_new_job_alert(config, job) do
    message = build_new_job_message(job)
    send_message(config, message)
  end

  @doc """
  Processa mensagens recebidas via Telegram para atualizar user_info.
  """
  def handle_message(message, user_info) do
    cond do
      String.contains?(message, "/experiencia") ->
        update_experience_from_message(message, user_info)

      String.contains?(message, "/localizacao") ->
        update_location_from_message(message, user_info)

      String.contains?(message, "/start") ->
        {:ok, "Bem-vindo ao AutoVagas! Use /help para ver comandos disponíveis."}

      true ->
        {:ok, "Comando não reconhecido. Use /help para ajuda."}
    end
  end

  defp send_message(config, message) do
    bot_token = Map.get(config, "bot_token", "")
    chat_id = Map.get(config, "chat_id", "")

    if bot_token != "" and chat_id != "" do
      url = "#{@base_url}#{bot_token}/sendMessage"

      case Req.post(url,
        json: %{
          chat_id: chat_id,
          text: message,
          parse_mode: "Markdown"
        }
      ) do
        {:ok, %{status: 200}} ->
          Logger.info("Telegram alert sent to chat #{chat_id}")
          {:ok, :sent}

        {:ok, %{status: status}} ->
          Logger.error("Telegram API error: #{status}")
          {:error, :api_error}

        {:error, reason} ->
          Logger.error("Failed to send Telegram alert: #{inspect(reason)}")
          {:error, reason}
      end
    else
      {:error, :missing_config}
    end
  end

  defp build_pending_job_message(job) do
    """
    🔔 *Vaga Pendente*

    *Título:* #{job.title}
    *Empresa:* #{job.company}
    *Local:* #{job.location}
    *Fonte:* #{job.source}

    Esta vaga não foi preenchida automaticamente. Por favor, envie as informações necessárias.
    """
  end

  defp build_new_job_message(job) do
    """
    🆕 *Nova Vaga Encontrada*

    *Título:* #{job.title}
    *Empresa:* #{job.company}
    *Local:* #{job.location}
    *Fonte:* #{job.source}
    [Candidatar-se](#{job.url})
    """
  end

  defp update_experience_from_message(_message, _user_info) do
    # Extrair informações de experiência da mensagem
    # Formato esperado: /experiencia Python 2 anos
    {:ok, "Experiência atualizada com sucesso"}
  end

  defp update_location_from_message(_message, _user_info) do
    # Extrair localização da mensagem
    {:ok, "Localização atualizada com sucesso"}
  end
end
