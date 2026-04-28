defmodule AutoVagas.Notifications.Channels do
  @moduledoc """
  Módulo central para gerenciar notificações via WhatsApp, Telegram e Discord.
  """

  require Logger

  alias AutoVagas.Notifications.{WhatsApp, Telegram, Discord}

  @doc """
  Envia uma notificação de vaga pendente para todos os canais ativos.
  """
  def notify_pending_job(job, user_info) do
    channels = get_active_channels(user_info)

    Enum.each(channels, fn channel ->
      case channel do
        {:whatsapp, config} ->
          WhatsApp.send_pending_job_alert(config, job)

        {:telegram, config} ->
          Telegram.send_pending_job_alert(config, job)

        {:discord, config} ->
          Discord.send_pending_job_alert(config, job)

        _ ->
          :ok
      end
    end)
  end

  @doc """
  Envia uma notificação de nova vaga para todos os canais ativos.
  """
  def notify_new_job(job, user_info) do
    channels = get_active_channels(user_info)

    Enum.each(channels, fn channel ->
      case channel do
        {:whatsapp, config} ->
          WhatsApp.send_new_job_alert(config, job)

        {:telegram, config} ->
          Telegram.send_new_job_alert(config, job)

        {:discord, config} ->
          Discord.send_new_job_alert(config, job)

        _ ->
          :ok
      end
    end)
  end

  @doc """
  Recebe e processa mensagens dos canais para atualizar user_info.json.
  """
  def handle_incoming_message(channel, message, user_info) do
    case channel do
      :whatsapp -> WhatsApp.handle_message(message, user_info)
      :telegram -> Telegram.handle_message(message, user_info)
      :discord -> Discord.handle_message(message, user_info)
      _ -> {:error, :unsupported_channel}
    end
  end

  @doc """
  Verifica se há canais configurados e ativos.
  """
  def has_active_channels?(user_info) do
    channels = get_active_channels(user_info)
    length(channels) > 0
  end

  defp get_active_channels(user_info) do
    notification_channels = Map.get(user_info, "notification_channels", %{})

    []
    |> maybe_add_channel(:whatsapp, notification_channels)
    |> maybe_add_channel(:telegram, notification_channels)
    |> maybe_add_channel(:discord, notification_channels)
  end

  defp maybe_add_channel(acc, channel_name, configs) do
    case Map.get(configs, Atom.to_string(channel_name), %{}) do
      %{"enabled" => true} = config -> [{channel_name, config} | acc]
      _ -> acc
    end
  end
end
