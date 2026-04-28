defmodule AutoVagas.Experience do
  @moduledoc """
  Módulo para calcular experiência profissional dinâmica.
  - Salva o ano inicial (initial_year_experience)
  - Calcula anos de experiência baseado no ano atual via NTP
  - Valida e atualiza anualmente ao iniciar o sistema
  """

  alias AutoVagas.NTP

  @doc """
  Inicializa o sistema de experiência.
  - Carrega user_info
  - Valida se é um novo ano e atualiza os cálculos usando NTP
  """
  @spec initialize() :: map()
  def initialize do
    user_info = AutoVagas.Crawler.UserConfig.load()
    experience = Map.get(user_info, "experience", %{})

    current_year = NTP.current_year()
    last_updated = Map.get(experience, "_meta", %{}) |> Map.get("last_year_checked", 0)

    if current_year > last_updated do
      updated = calculate_all_experience(experience, current_year)
      save_experience(updated, current_year)
      updated
    else
      experience
    end
  end

  @doc """
  Retorna anos de experiência para uma tecnologia.
  Se a experiência for expressa em anos (ex: "2 anos"), converte para ano inicial.
  """
  @spec get_years(String.t()) :: integer()
  def get_years(technology) do
    experience = initialize()
    data = Map.get(experience, technology, %{})

    case data do
      %{"years" => years} when is_integer(years) ->
        years

      %{"initial_year" => initial_year} ->
        current_year() - initial_year

      _ ->
        0
    end
  end

  @doc """
  Retorna anos de experiência para uma tecnologia no formato string.
  """
  @spec get_years_formatted(String.t()) :: String.t()
  def get_years_formatted(technology) do
    years = get_years(technology)
    format_years(years)
  end

  @doc """
  Converte anos de experiência para string formatada (ex: "5+ anos", "1 ano", "6 meses").
  """
  @spec format_years(integer()) :: String.t()
  def format_years(years) when years >= 5 do
    "#{years}+ anos"
  end

  def format_years(1) do
    "1 ano"
  end

  def format_years(years) when years > 1 do
    "#{years} anos"
  end

  def format_years(0) do
    "< 1 ano"
  end

  @doc """
  Retorna todas as tecnologias com experiência.
  """
  @spec all_technologies() :: [String.t()]
  def all_technologies do
    experience = initialize()
    Map.keys(experience) |> Enum.reject(&String.starts_with?(&1, "_"))
  end

  @doc """
  Adiciona experiência a partir de anos declarados (ex: "2 anos").
  """
  @spec add_by_years(String.t(), String.t()) :: :ok
  def add_by_years(technology, years_string) do
    years = parse_years_string(years_string)
    initial_year = current_year() - years

    add_technology(technology, initial_year, years)
  end

  @doc """
  Adiciona tecnologia com ano inicial.
  """
  @spec add_technology(String.t(), integer(), integer()) :: :ok
  def add_technology(technology, initial_year, years) do
    experience = initialize()

    updated = Map.put(experience, technology, %{
      "initial_year" => initial_year,
      "years" => years,
      "added_at" => DateTime.utc_now() |> DateTime.to_iso8601()
    })

    save_experience(updated, current_year())
  end

  @doc """
  Remove tecnologia da experiência.
  """
  @spec remove_technology(String.t()) :: :ok
  def remove_technology(technology) do
    experience = initialize()
    updated = Map.delete(experience, technology)
    save_experience(updated, current_year())
  end

  @doc """
  Retorna experiência no formato para formulários de vagas.
  """
  @spec for_application() :: map()
  def for_application do
    _experience = initialize()
    technologies = all_technologies()

    Enum.reduce(technologies, %{}, fn tech, acc ->
      Map.put(acc, tech, get_years(tech))
    end)
  end

  defp calculate_all_experience(experience, current_year) do
    Enum.reduce(experience, experience, fn
      {"_meta", _}, acc -> acc
      {tech, %{"initial_year" => initial_year}}, acc ->
        years = current_year - initial_year
        Map.put(acc, tech, %{"initial_year" => initial_year, "years" => years})
      {tech, %{"years" => years}}, acc ->
        Map.put(acc, tech, %{"years" => years})
      _, acc -> acc
    end)
  end

  defp save_experience(experience, current_year) do
    meta = Map.get(experience, "_meta", %{})
    updated_meta = Map.put(meta, "last_year_checked", current_year)
    experience = Map.put(experience, "_meta", updated_meta)

    user_info = AutoVagas.Crawler.UserConfig.load()
    updated = Map.put(user_info, "experience", experience)
    AutoVagas.Crawler.UserConfig.save(updated)
  end

  defp current_year do
    Date.utc_today().year
  end

  defp parse_years_string(string) do
    string
    |> String.replace(~r/\D/, "")
    |> String.to_integer()
  rescue
    _ -> 0
  end
end