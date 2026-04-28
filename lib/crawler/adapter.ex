defmodule AutoVagas.Crawler.Adapter do
  @moduledoc """
  Behavior e funções utilitárias para adaptadores de sites de vagas.

  O adapter é responsável por:
  1. Carregar configurações e preferências do usuário
  2. Aplicar filtros ativos
  3. Passar parâmetros padronizados para os sites
  """

  @callback config() :: map()
  @callback build_url(
              search_term :: String.t(),
              location :: String.t(),
              time_posted :: String.t(),
              work_type :: String.t(),
              user_config :: map()
            ) :: String.t()
  @callback build_urls([String.t()], keyword(), user_config :: map()) :: [
              {String.t(), String.t()}
            ]
  @callback parse(html :: String.t()) :: list()

  @doc """
  Seleciona o adapter correto baseado na fonte.
  """
  @spec adapter_for(String.t()) :: module()
  def adapter_for("linkedin"), do: AutoVagas.Crawler.Sites.LinkedIn
  def adapter_for("indeed"), do: AutoVagas.Crawler.Sites.Indeed
  def adapter_for("gupy"), do: AutoVagas.Crawler.Sites.Gupy
  def adapter_for(_), do: nil
end

defmodule AutoVagas.Crawler.UserConfig do
  @moduledoc """
  Módulo para carregar configurações do usuário.
  """

  @user_info_path "priv/user_info.json"

  @doc """
  Carrega configurações do usuário.
  """
  @spec load() :: map()
  def load do
    if File.exists?(@user_info_path) do
      @user_info_path
      |> File.read!()
      |> Jason.decode!()
    else
      default_config()
    end
  rescue
    _ -> default_config()
  end

  @doc """
  Salva configurações do usuário.
  """
  @spec save(map()) :: :ok
  def save(config) do
    File.write!(@user_info_path, Jason.encode!(config, pretty: true))
  end

  @doc """
  Carrega preferências específicas por fonte.
  """
  @spec source_config(String.t()) :: map()
  def source_config(source) do
    config = load()
    filters = Map.get(config, "filters", %{})
    by_source = Map.get(filters, "by_source", %{})
    Map.get(by_source, source, %{})
  end

  @doc """
  Retorna os filtros globais.
  """
  @spec global_filters() :: map()
  def global_filters do
    config = load()
    filters = Map.get(config, "filters", %{})
    Map.get(filters, "global", %{})
  end

  @doc """
  Retorna configurações de trabalho.
  """
  @spec work_config() :: map()
  def work_config do
    config = load()

    Map.get(config, "work_configs", %{
      "on_site" => %{"max_distance_km" => 30, "countries" => []},
      "hybrid" => %{"max_distance_km" => 50, "countries" => []},
      "remote" => %{"max_distance_km" => nil, "countries" => []}
    })
  end

  @doc """
  Retorna idiomas configurados.
  """
  @spec languages() :: [String.t()]
  def languages do
    config = load()
    Map.get(config, "languages", [])
  end

  @doc """
  Retorna localização padrão.
  """
  @spec default_location() :: String.t()
  def default_location do
    config = load()
    Map.get(config, "location", "Brazil")
  end

  @doc """
  Retorna localização completa do usuário com cidade, estado e país.
  """
  @spec user_location() :: map()
  def user_location do
    config = load()

    Map.get(config, "user_location", %{
      "country" => "Brazil",
      "state" => "",
      "city" => ""
    })
  end

  @doc """
  Retorna coordenadas do usuário via API do Google Maps.
  """
  @spec user_coordinates() :: {float(), float()} | nil
  def user_coordinates do
    location = user_location()
    city = Map.get(location, "city", "")
    state = Map.get(location, "state", "")
    country = Map.get(location, "country", "")

    if city != "" do
      AutoVagas.Crawler.Geolocation.get_coordinates(city, state, country)
    else
      nil
    end
  end

  @doc """
  Retorna filtros padrão.
  """
  @spec default_filters() :: map()
  def default_filters do
    config = load()

    Map.get(config, "default_filters", %{
      "time_posted" => "r86400",
      "work_type" => "all"
    })
  end

  defp default_config do
    %{
      "location" => "Brazil",
      "languages" => [],
      "default_filters" => %{
        "time_posted" => "r86400",
        "work_type" => "all"
      },
      "work_configs" => %{
        "on_site" => %{"max_distance_km" => 30, "countries" => []},
        "hybrid" => %{"max_distance_km" => 50, "countries" => []},
        "remote" => %{"max_distance_km" => nil, "countries" => []}
      },
      "filters" => %{
        "global" => %{},
        "by_source" => %{}
      }
    }
  end
end
