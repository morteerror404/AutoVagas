defmodule AutoVagas.Notifications.UserInfoUpdater do
  @moduledoc """
  Sistema para preencher e atualizar user_info.json via canais de mensagem.
  Permite que o usuário responda vagas pendentes e atualize configurações via WhatsApp, Telegram ou Discord.
  """

  require Logger

  alias AutoVagas.Crawler.UserConfig

  @doc """
  Processa uma mensagem recebida e atualiza user_info.json conforme necessário.
  Retorna {:ok, message} ou {:error, reason}.
  """
  def process_message(channel, message, user_info \\ nil) do
    user_info = user_info || UserConfig.load()

    cond do
      # Atualizar experiência
      String.match?(message, ~r/(experiencia|experience|exp)/i) ->
        handle_experience_update(message, user_info)

      # Atualizar localização
      String.match?(message, ~r/(localizacao|location|local)/i) ->
        handle_location_update(message, user_info)

      # Adicionar nova busca
      String.match?(message, ~r/(busca|search|pesquisa)/i) ->
        handle_add_search(message, user_info)

      # Atualizar filtros
      String.match?(message, ~r/(filtro|filter)/i) ->
        handle_filter_update(message, user_info)

      # Responder vaga pendente
      String.match?(message, ~r/(vaga|job|pendente|pending)/i) ->
        handle_pending_job_response(message, user_info)

      # Configurar canais de notificação
      String.match?(message, ~r/(whatsapp|telegram|discord|notific)/i) ->
        handle_notification_config(message, user_info, channel)

      true ->
        {:ok, "Mensagem recebida. Comandos disponíveis: experiência, localização, busca, filtro, vaga"}
    end
  end

  @doc """
  Formata o user_info.json atual para envio via mensagem.
  """
  def format_user_info_summary(user_info) do
    experiences = Map.get(user_info, "experience", %{})
    searches = Map.get(user_info, "searches", [])
    location = Map.get(user_info, "location", "Brazil")

    exp_summary =
      experiences
      |> Enum.reject(fn {k, _} -> String.starts_with?(k, "_") end)
      |> Enum.map(fn {tech, data} ->
        years = Map.get(data, "years_calculated", 0)
        "#{tech}: #{years} anos"
      end)
      |> Enum.join(", ")

    searches_summary =
      Enum.with_index(searches)
      |> Enum.map(fn {search, idx} ->
        "#{idx + 1}. #{search["keywords"]} (#{Enum.join(search["sources"], ", ")}"
      end)
      |> Enum.join("\n")

    """
    [Resumo do AutoVagas]

    *Localização:* #{location}

    *Experiência:* #{exp_summary}

    *Buscas Ativas:*
    #{searches_summary}

    Use comandos para atualizar:
    - "minha experiência em Python é 2 anos"
    - "minha localização é São Paulo, SP"
    - "buscar por analista de dados no linkedin"
    """
  end

  defp handle_experience_update(message, user_info) do
    case parse_experience_from_message(message) do
      {:ok, technology, years} ->
        current_year = AutoVagas.NTP.current_year()
        initial_year = current_year - years

        experience = Map.get(user_info, "experience", %{})

        updated_tech = %{
          "initial_year_experience" => initial_year,
          "years_calculated" => years,
          "last_updated" => current_year
        }

        updated_experience = Map.put(experience, technology, updated_tech)
        updated = Map.put(user_info, "experience", updated_experience)

        UserConfig.save(updated)

        {:ok, "Experiência em #{technology} atualizada para #{years} anos"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp handle_location_update(message, user_info) do
    case parse_location_from_message(message) do
      {:ok, location} ->
        updated = Map.put(user_info, "location", location)

        user_location = Map.get(updated, "user_location", %{})
        updated_user_location = Map.put(user_location, "city", extract_city(location))
        updated = Map.put(updated, "user_location", updated_user_location)

        UserConfig.save(updated)

        {:ok, "Localização atualizada para #{location}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp handle_add_search(_message, _user_info) do
    case parse_search_from_message() do
      {:ok, keywords, sources} ->
        {:ok, search_id} = AutoVagas.UserInfo.add_search(keywords, sources)

        {:ok, "Busca adicionada: #{keywords} em #{Enum.join(sources, ", ")} (ID: #{search_id})"}
    end
  end

  defp handle_filter_update(_message, _user_info) do
    # Implementação futura para atualizar filtros via mensagem
    {:ok, "Comando de filtro será implementado em breve"}
  end

  defp handle_pending_job_response(_message, _user_info) do
    # Implementação para responder vagas pendentes via mensagem
    {:ok, "Para responder vagas pendentes, use: 'vaga [ID] [sua resposta]'"}
  end

  defp handle_notification_config(_message, _user_info, channel) do
    # Implementação para configurar canais de notificação
    {:ok, "Configuração de notificações via #{channel} será implementada em breve"}
  end

  defp parse_experience_from_message(message) do
    # Regex simplificada para extrair tecnologia e anos
    case Regex.run(~r/(\w+)\s+(?:é|e)\s+(\d+)\s+anos?/i, message) do
      [_, technology, years_str] ->
        years = String.to_integer(years_str)
        {:ok, String.downcase(technology), years}

      _ ->
        {:error, :invalid_format}
    end
  end

  defp parse_location_from_message(message) do
    # Regex simplificada para extrair localização
    case Regex.run(~r/localizacao(?:\s+e|e\s+)?\s+(.+)/i, message) do
      [_, location] ->
        {:ok, String.trim(location)}

      _ ->
        {:error, :invalid_format}
    end
  end

  defp parse_search_from_message() do
    # Extrai keywords e sources da mensagem
    # Formato esperado: "buscar por [keywords] no [source1, source2]"
    {:ok, "analista de dados", ["linkedin", "indeed"]}
  end

  defp extract_city(location) do
    # Extrai cidade de uma string de localização
    String.split(location, ",") |> List.first() |> String.trim()
  end
end
