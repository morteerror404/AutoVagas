defmodule AutoVagas.UserInfo do
  @moduledoc """
  Gerencia o arquivo user_info.json com suporte a múltiplas buscas simultâneas.
  Cada busca pode ter parâmetros diferentes (keywords, sources, filters).
  """

  @user_info_path "priv/user_info.json"

  @doc """
  Carrega user_info.json.
  """
  def load do
    case File.read(@user_info_path) do
      {:ok, content} ->
        case Jason.decode(content) do
          {:ok, data} -> data
          {:error, _} -> default_user_info()
        end
      {:error, _} ->
        default_user_info()
    end
  end

  @doc """
  Salva user_info.json.
  """
  def save(user_info) do
    with {:ok, content} <- Jason.encode(user_info, pretty: true),
         :ok <- File.write(@user_info_path, content) do
      :ok
    end
  end

  defp default_user_info do
    %{
      "rules" => [],
      "searches" => [],
      "languages" => ["pt-BR", "en-US"],
      "country" => "Brazil",
      "state" => "",
      "city" => "",
      "experience" => %{},
      "skills" => %{}
    }
  end

  @doc """
  Adiciona uma nova busca às configurações do usuário.
  Retorna o ID da busca criada.
  """
  def add_search(keywords, sources, opts \\ []) do
    user_info = load()

    search_config = %{
      "keywords" => keywords,
      "sources" => sources,
      "location" => Keyword.get(opts, :location, "Brazil"),
      "filters" => Keyword.get(opts, :filters, %{}),
      "time_posted" => Keyword.get(opts, :time_posted, "r86400"),
      "work_type" => Keyword.get(opts, :work_type, "all"),
      "active" => true,
      "id" => System.unique_integer([:positive]),
      "created_at" => DateTime.utc_now() |> DateTime.to_iso8601()
    }

    searches = Map.get(user_info, "searches", [])
    updated_searches = [search_config | searches]

    updated = Map.put(user_info, "searches", updated_searches)
    save(updated)

    {:ok, search_config["id"]}
  end

  @doc """
  Lista todas as buscas configuradas.
  """
  def list_searches do
    user_info = load()
    Map.get(user_info, "searches", [])
  end

  @doc """
  Remove uma busca das configurações.
  """
  def remove_search(search_id) when is_integer(search_id) or is_binary(search_id) do
    user_info = load()
    searches = Map.get(user_info, "searches", [])

    updated_searches = Enum.reject(searches, fn s -> Map.get(s, "id") == search_id end)

    updated = Map.put(user_info, "searches", updated_searches)
    save(updated)
  
  end

  @doc """
  Atualiza o campo experience no user_info.json com initial_year_experience.
  Calcula anos de experiência baseado no ano atual via NTP.
  """
  def update_experience_years do
    user_info = load()
    experience = Map.get(user_info, "experience", %{})
    
    current_year = AutoVagas.NTP.current_year()
    
    updated_experience = Map.new(experience, fn
      {"_meta", value} -> {"_meta", value}
      {key, %{"years" => years}} ->
        initial_year = current_year - years
        updated_meta = Map.put(Map.get(experience, "_meta", %{}), key, initial_year)
        {{key, %{"years" => years}}, {"_meta", updated_meta}}
      {key, value} -> {key, value}
    end)
    
    updated = Map.put(user_info, "experience", updated_experience)
    save(updated)
    
    updated_experience
  end
end
