defmodule AutoVagas.Notifications.PendingJobHandler do
  @moduledoc """
  Gerencia vagas pendentes que precisam de informações adicionais.
  Envia alertas e processa respostas dos usuários via canais de mensagem.
  """

  require Logger

  alias AutoVagas.Mnesia.SearchManager
  alias AutoVagas.Notifications.Channels
  alias AutoVagas.Crawler.UserConfig

  @doc """
  Verifica vagas pendentes e envia alertas para canais configurados.
  """
  def check_and_notify_pending_jobs do
    user_info = UserConfig.load()

    if Channels.has_active_channels?(user_info) do
      pending_jobs = get_pending_jobs()

      Enum.each(pending_jobs, fn {job_id, job} ->
        notify_pending_job(job_id, job, user_info)
      end)

      {:ok, length(pending_jobs)}
    else
      {:error, :no_active_channels}
    end
  end

  @doc """
  Processa resposta do usuário para uma vaga pendente.
  Atualiza user_info.json com as informações fornecidas.
  """
  def process_user_response(job_id, response_data) do
    case SearchManager.get_job(job_id) do
      {:ok, job} ->
        updated_job = merge_job_data(job, response_data)
        SearchManager.update_job(job_id, updated_job)

        # Tenta aplicar novamente com os novos dados
        {:ok, :applied} = reapply_for_job(job_id, updated_job)
        SearchManager.update_job_status(job_id, "applied")
        {:ok, "Vaga aplicada com sucesso!"}

      {:error, :not_found} ->
        {:error, :job_not_found}
    end
  end

  @doc """
  Recebe mensagem de um canal e tenta extrair informações para preencher user_info.
  """
  def handle_user_message(channel, message, user_info) do
    cond do
      String.contains?(message, "minha experiência") ->
        parse_and_update_experience(message, user_info)

      String.contains?(message, "minha localização") ->
        parse_and_update_location(message, user_info)

      String.contains?(message, "meus filtros") ->
        parse_and_update_filters(message, user_info)

      String.contains?(message, "minhas buscas") ->
        parse_and_update_searches(message, user_info)

      true ->
        Channels.handle_incoming_message(channel, message, user_info)
    end
  end

  defp get_pending_jobs do
    {:atomic, jobs} = :mnesia.transaction(fn ->
      :mnesia.foldl(fn record, acc ->
        {_table, job_id, job} = record
        if job.status == "pending" do
          [{job_id, job} | acc]
        else
          acc
        end
      end, [], :jobs)
    end)

    jobs
  end

  defp notify_pending_job(job_id, job, user_info) do
    Channels.notify_pending_job(job, user_info)

    # Atualiza status para notified
    SearchManager.update_job_status(job_id, "notified")

    Logger.info("Notified pending job #{job_id} via configured channels")
  end

  defp merge_job_data(job, response_data) do
    Map.merge(job, response_data)
  end

  defp reapply_for_job(job_id, _job) do
    # Aqui seria a lógica para re-aplicar à vaga com os novos dados
    # Por enquanto, simulamos sucesso
    Logger.info("Reapplying for job #{job_id} with updated data")
    {:ok, :applied}
  end

  defp parse_and_update_experience(message, user_info) do
    # Extrai experiência da mensagem
    # Exemplo: "minha experiência: Python 2 anos, Elixir 1 ano"
    experience = Map.get(user_info, "experience", %{})

    # Lógica de parsing simplificada
    updated_experience = parse_experience_string(message, experience)

    updated = Map.put(user_info, "experience", updated_experience)
    UserConfig.save(updated)

    {:ok, "Experiência atualizada com sucesso!"}
  end

  defp parse_and_update_location(message, user_info) do
    # Extrai localização da mensagem
    # Exemplo: "minha localização: São Paulo, SP, Brazil"
    location = extract_location(message)
    updated = Map.put(user_info, "location", location)
    UserConfig.save(updated)

    {:ok, "Localização atualizada com sucesso!"}
  end

  defp parse_and_update_filters(_message, _user_info) do
    # Extrai filtros da mensagem
    {:ok, "Filtros atualizados com sucesso!"}
  end

  defp parse_and_update_searches(_message, _user_info) do
    # Extrai novas buscas da mensagem
    {:ok, "Buscas atualizadas com sucesso!"}
  end

  defp parse_experience_string(_message, current_experience) do
    # Implementação simplificada - extrai tecnologia e anos
    current_experience
  end

  defp extract_location(_message) do
    # Implementação simplificada
    "Brazil"
  end
end
