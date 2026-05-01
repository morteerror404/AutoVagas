defmodule AutoVagas.Notifications.WhatsApp do
  @moduledoc """
  Integração inicial com WhatsApp para alertas de vagas.
  Suporta WhatsApp Business API ou bibliotecas como whatsapp_ex.
  """

  require Logger

  @doc """
  Envia alerta de vaga pendente via WhatsApp.
  """
  def send_pending_job_alert(config, job) do
    message = build_pending_job_message(job)

    case send_message(config, message) do
      {:ok, _} ->
        Logger.info("WhatsApp alert sent for pending job: #{job.title}")
        :ok

      {:error, reason} ->
        Logger.error("Failed to send WhatsApp alert: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Envia alerta de nova vaga via WhatsApp.
  """
  def send_new_job_alert(config, job) do
    message = build_new_job_message(job)

    case send_message(config, message) do
      {:ok, _} ->
        Logger.info("WhatsApp alert sent for new job: #{job.title}")
        :ok

      {:error, reason} ->
        Logger.error("Failed to send WhatsApp alert: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Processa mensagens recebidas via WhatsApp para atualizar user_info.
  """
  def handle_message(message, user_info) do
    cond do
      String.contains?(message, "minha experiência") ->
        update_experience_from_message(message, user_info)

      String.contains?(message, "minha localização") ->
        update_location_from_message(message, user_info)

      true ->
        {:ok, "Mensagem recebida, mas não entendi o comando"}
    end
  end

  defp send_message(config, message) do
    phone_number = Map.get(config, "phone_number", "")
    api_key = Map.get(config, "api_key", "")

    if phone_number != "" and api_key != "" do
      # Aqui seria a integração real com WhatsApp Business API
      # Por enquanto, logamos apenas
      Logger.info("Would send WhatsApp to #{phone_number}: #{message}")

      # Exemplo de chamada HTTP (comentado):
      # Req.post("https://graph.facebook.com/v12.0/#{phone_number}/messages",
      #   headers: [{"Authorization", "Bearer #{api_key}"}],
      #   json: %{messaging_product: "whatsapp", to: phone_number, text: %{body: message}}
      # )

      {:ok, :queued}
    else
      {:error, :missing_config}
    end
  end

  defp build_pending_job_message(job) do
    """
    [Vaga Pendente]

    Titulo: #{job.title}
    Empresa: #{job.company}
    Local: #{job.location}
    Fonte: #{job.source}

    Esta vaga nao foi preenchida automaticamente. Por favor, envie as informacoes necessarias.
    """
  end

  defp build_new_job_message(job) do
    """
    [Nova Vaga Encontrada]

    Titulo: #{job.title}
    Empresa: #{job.company}
    Local: #{job.location}
    Fonte: #{job.source}
    URL: #{job.url}
    """
  end

  defp update_experience_from_message(_message, _user_info) do
    # Implementar lógica para extrair experiência da mensagem
    # Exemplo: "minha experiência em Python é de 2 anos"
    {:ok, "Experiência atualizada com sucesso"}
  end

  defp update_location_from_message(_message, _user_info) do
    # Implementar lógica para extrair localização da mensagem
    {:ok, "Localização atualizada com sucesso"}
  end
end
