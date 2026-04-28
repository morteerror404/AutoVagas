defmodule AutoVagas.Notifications.Discord do
  @moduledoc """
  Integração inicial com Discord para alertas de vagas.
  Usa Webhooks do Discord.
  """

  require Logger

  @doc """
  Envia alerta de vaga pendente via Discord.
  """
  def send_pending_job_alert(config, job) do
    embed = build_pending_job_embed(job)
    send_webhook(config, embed)
  end

  @doc """
  Envia alerta de nova vaga via Discord.
  """
  def send_new_job_alert(config, job) do
    embed = build_new_job_embed(job)
    send_webhook(config, embed)
  end

  @doc """
  Processa mensagens recebidas via Discord para atualizar user_info.
  NOTA: Discord Webhooks são unidirecionais (envio apenas).
  Para receber mensagens, seria necessário um bot completo.
  """
  def handle_message(_message, _user_info) do
    {:ok, "Discord webhook é apenas para envio. Para interação, considere usar um bot."}
  end

  defp send_webhook(config, embed) do
    webhook_url = Map.get(config, "webhook_url", "")

    if webhook_url != "" do
      payload = %{
        embeds: [embed],
        username: "AutoVagas Bot"
      }

      case Req.post(webhook_url, json: payload) do
        {:ok, %{status: 204}} ->
          Logger.info("Discord alert sent successfully")
          {:ok, :sent}

        {:ok, %{status: status}} ->
          Logger.error("Discord webhook error: #{status}")
          {:error, :webhook_error}

        {:error, reason} ->
          Logger.error("Failed to send Discord alert: #{inspect(reason)}")
          {:error, reason}
      end
    else
      {:error, :missing_config}
    end
  end

  defp build_pending_job_embed(job) do
    %{
      title: "🔔 Vaga Pendente",
      description: "Esta vaga não foi preenchida automaticamente.",
      color: 16_711_680,
      fields: [
        %{name: "Título", value: job.title, inline: true},
        %{name: "Empresa", value: job.company, inline: true},
        %{name: "Local", value: job.location, inline: true},
        %{name: "Fonte", value: job.source, inline: true}
      ],
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    }
  end

  defp build_new_job_embed(job) do
    %{
      title: "🆕 Nova Vaga Encontrada",
      description: "Uma nova vaga foi encontrada para sua busca!",
      color: 576_3719,
      fields: [
        %{name: "Título", value: job.title, inline: true},
        %{name: "Empresa", value: job.company, inline: true},
        %{name: "Local", value: job.location, inline: true},
        %{name: "Fonte", value: job.source, inline: true},
        %{name: "URL", value: job.url, inline: false}
      ],
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    }
  end
end
