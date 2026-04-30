defmodule AutoVagas.Crawler.Geolocation do
  @moduledoc """
  Módulo para obter coordenadas geográficas via Google Geocoding API.
  """

  @doc """
  Obtém coordenadas (lat, lng) a partir de cidade, estado e país.
  """
  @spec get_coordinates(String.t(), String.t(), String.t()) :: {float(), float()} | nil
  def get_coordinates(city, state, country) do
    address = build_address(city, state, country)

    case fetch_coordinates(address) do
      {:ok, coords} -> coords
      _ -> nil
    end
  end

  @doc """
  Obtém coordenadas a partir de uma string de localização.
  """
  @spec get_coordinates_from_string(String.t()) :: {float(), float()} | nil
  def get_coordinates_from_string(location) when is_binary(location) do
    case fetch_coordinates(location) do
      {:ok, coords} -> coords
      _ -> nil
    end
  end

  @doc """
  Calcula distância entre dois pontos usando fórmula de Haversine.
  Retorna distância em quilômetros.
  """
  @spec calculate_distance({float(), float()}, {float(), float()}) :: float()
  def calculate_distance({lat1, lon1}, {lat2, lon2}) do
    r = 6371

    dlat = to_radians(lat2 - lat1)
    dlon = to_radians(lon2 - lon1)

    a =
      :math.sin(dlat / 2) * :math.sin(dlat / 2) +
        :math.cos(to_radians(lat1)) * :math.cos(to_radians(lat2)) *
          :math.sin(dlon / 2) * :math.sin(dlon / 2)

    c = 2 * :math.atan2(:math.sqrt(a), :math.sqrt(1 - a))

    r * c
  end

  @doc """
  Verifica se uma localização está dentro do raio especificado.
  """
  @spec within_radius?({float(), float()}, {float(), float()}, float()) :: boolean()
  def within_radius?(user_coords, job_coords, radius_km) do
    distance = calculate_distance(user_coords, job_coords)
    distance <= radius_km
  end

  defp build_address(city, state, country) do
    parts = [city, state, country] |> Enum.reject(&(&1 == ""))
    Enum.join(parts, ", ")
  end

  defp to_radians(degrees) do
    degrees * :math.pi() / 180
  end

  defp fetch_coordinates(address) do
    api_key = System.get_env("GOOGLE_MAPS_API_KEY")

    if api_key do
      url =
        "https://maps.googleapis.com/maps/api/geocode/json?address=#{URI.encode(address)}&key=#{api_key}"

      case Req.get(url) do
        {:ok, response} ->
          body = response.body
          results = Map.get(body, "results", [])

          case List.first(results) do
            nil ->
              nil

            result ->
              geometry = Map.get(result, "geometry", %{})
              location = Map.get(geometry, "location", %{})
              lat = Map.get(location, "lat")
              lng = Map.get(location, "lng")

              if lat && lng do
                {:ok, {lat, lng}}
              else
                nil
              end
          end

        _ ->
          nil
      end
    else
      {:error, "API key não configurada"}
    end
  rescue
    _ -> nil
  end
end
