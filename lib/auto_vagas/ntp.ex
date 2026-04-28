defmodule AutoVagas.NTP do
  @moduledoc """
  Cliente NTP simples para obter tempo preciso via rede.
  Usa o protocolo NTP para sincronização de tempo.
  """

  require Logger

  @ntp_servers [
    "pool.ntp.org:123",
    "time.google.com:123",
    "time.windows.com:123"
  ]

  @timeout 5_000

  @doc """
  Obtém a data/hora atual via NTP.
  Retorna {:ok, DateTime.t()} ou {:error, reason}.
  """
  def now do
    Enum.find_value(@ntp_servers, {:error, :no_servers_available}, fn server ->
      case fetch_time(server) do
        {:ok, datetime} -> {:ok, datetime}
        _ -> nil
      end
    end)
  end

  @doc """
  Obtém o ano atual via NTP.
  """
  def current_year do
    case now() do
      {:ok, datetime} -> DateTime.to_date(datetime).year
      {:error, _} ->
        Logger.warning("NTP failed, falling back to system time")
        Date.utc_today().year
    end
  end

  defp fetch_time(server) do
    {host, port} = parse_server(server)

    case :gen_udp.open(0, [:binary, active: false]) do
      {:ok, socket} ->
        try do
          packet = build_ntp_packet()
          :gen_udp.send(socket, host, port, packet)

          case :gen_udp.recv(socket, 48, @timeout) do
            {:ok, {_ip, _port, data}} ->
              parse_ntp_response(data)

            {:error, reason} ->
              {:error, reason}
          end
        rescue
          e -> {:error, e}
        after
          :gen_udp.close(socket)
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp parse_server(server) do
    case String.split(server, ":") do
      [host, port] -> {String.to_charlist(host), String.to_integer(port)}
      [host] -> {String.to_charlist(host), 123}
    end
  end

  defp build_ntp_packet do
    <<
      # LI (0), Version (3), Mode (3 - client)
      0b00110011,
      # Stratum, Poll, Precision
      0, 0, 0,
      # Root Delay, Root Dispersion
      0::32, 0::32,
      # Reference ID
      0::32,
      # Reference Timestamp
      0::64,
      # Originate Timestamp
      0::64,
      # Receive Timestamp
      0::64,
      # Transmit Timestamp (we need this)
      0::64
    >>
  end

  defp parse_ntp_response(<<_::40-bytes, transmit_timestamp::64, _::binary>>) do
    # NTP timestamp: seconds since 1900-01-01
    # Unix timestamp: seconds since 1970-01-01
    # Difference: 2_208_988_800 seconds

    # Extract seconds from the 64-bit timestamp (first 32 bits are seconds)
    <<ntp_seconds::32, _fraction::32>> = <<transmit_timestamp::64>>
    unix_seconds = ntp_seconds - 2_208_988_800

    case DateTime.from_unix(unix_seconds) do
      {:ok, datetime} -> {:ok, datetime}
      error -> error
    end
  end

  defp parse_ntp_response(_), do: {:error, :invalid_response}
end
