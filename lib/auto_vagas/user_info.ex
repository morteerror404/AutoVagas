defmodule AutoVagas.UserInfo do
  @moduledoc """
  Gerencia o arquivo user_info.json com suporte a múltiplas buscas simultâneas.
  Cada busca pode ter parâmetros diferentes (keywords, sources, filters).
  """

  alias AutoVagas.Crawler.UserConfig
  alias AutoVagas.Mnesia.SearchManager

  @doc """
  Adiciona uma nova busca às configurações do usuário.
  Retorna o ID da busca criada.
  """
  def add_search(keywords, sources, opts \\ []) do
    user_info = UserConfig.load()

    search_config = %{
      "keywords" => keywords,
      "sources" => sources,
      "location" => Keyword.get(opts, :location, "Brazil"),
      "filters" => Keyword.get(opts, :filters, %{}),
      "time_posted" => Keyword.get(opts, :time_posted, "r86400"),
      "work_type" => Keyword.get(opts, :work_type, "all"),
      "active" => true,
      "created_at" => DateTime.utc_now() |> DateTime.to_iso8601()
    }

    searches = Map.get(user_info, "searches", [])
    updated_searches = [search_config | searches]

    updated = Map.put(user_info, "searches", updated_searches)
    UserConfig.save(updated)

    # Também cria no Mnesia para execução
    {:ok, search_id} = SearchManager.create_search(keywords, sources,
      location: search_config["location"],
      filters: search_config["filters"]
    )

    {:ok, search_id}
  end

  @doc """
  Lista todas as buscas configuradas.
  """
  def list_searches do
    user_info = UserConfig.load()
    Map.get(user_info, "searches", [])
  end

  @doc """
  Remove uma busca das configurações.
  """
  def remove_search(index) when is_integer(index) do
    user_info = UserConfig.load()
    searches = Map.get(user_info, "searches", [])

    if index >= 0 and index < length(searches) do
      updated_searches = List.delete_at(searches, index)
      updated = Map.put(user_info, "searches", updated_searches)
      UserConfig.save(updated)
      :ok
    else
      {:error, :invalid_index}
    end
  end

  @doc """
  Atualiza o campo experience no user_info.json com initial_year_experience.
  Calcula anos de experiência baseado no ano atual via NTP.
  """
  def update_experience_years do
    user_info = UserConfig.load()
    experience = Map.get(user_info, "experience", %{})

    current_year = AutoVagas.NTP.current_year()

    updated_experience = Map.new(experience, fn
      {"_meta", value} -> {"_meta", value}
      {key, %{"years" => years}} ->
        initial_year = current_year - years
        {key, %{
          "initial_year_experience" => initial_year,
          "years_calculated" => years,
          "last_updated" => current_year
        }}
      {key, %{"initial_year" => initial_year}} ->
        years = current_year - initial_year
        {key, %{
          "initial_year_experience" => initial_year,
          "years_calculated" => years,
          "last_updated" => current_year
        }}
      {key, value} -> {key, value}
    end)

    updated_meta = Map.put(updated_experience, "_meta", %{
      "last_year_checked" => current_year,
      "updated_via" => "NTP"
    })

    updated = Map.put(user_info, "experience", updated_meta)
    UserConfig.save(updated)

    updated_meta
  end

  @doc """
  Salva user_info.json.
  """
  def save(user_info) do
    UserConfig.save(user_info)
  end
end
