defmodule AutoVagas.Crawler.AuthSession do
  @moduledoc """
  Gerencia sessões autenticadas para cada fonte de vagas.
  As sessões são armazenadas em memória e reutilizadas.
  """

  use GenServer

  @doc """
  Inicia o servidor de sessões.
  """
  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Inicializa o estado vazio.
  """
  def init(:ok) do
    {:ok, %{}}
  end

  @doc """
  Cria uma sessão autenticada para a fonte.
  """
  @spec create_session(String.t(), String.t(), String.t()) :: :ok | {:error, any()}
  def create_session(source, username, password) do
    GenServer.call(__MODULE__, {:create_session, source, username, password})
  end

  @doc """
  Obtém os cookies de uma sessão autenticada.
  """
  @spec get_cookies(String.t()) :: [map()]
  def get_cookies(source) do
    GenServer.call(__MODULE__, {:get_cookies, source})
  end

  @doc """
  Verifica se uma sessão está ativa.
  """
  @spec active?(String.t()) :: boolean()
  def active?(source) do
    GenServer.call(__MODULE__, {:active?, source})
  end

  @doc """
  Remove a sessão autenticada.
  """
  def delete_session(source) do
    GenServer.call(__MODULE__, {:delete_session, source})
  end

  @doc """
  Atualiza os cookies de uma sessão (após request).
  """
  @spec update_cookies(String.t(), [map()]) :: :ok
  def update_cookies(source, cookies) do
    GenServer.call(__MODULE__, {:update_cookies, source, cookies})
  end

  # GenServer callbacks

  def handle_call({:create_session, source, username, password}, _from, state) do
    {:ok, session_data} = AutoVagas.Crawler.Auth.start_session(source)
    {:ok, session_data} = AutoVagas.Crawler.Auth.login(session_data, username, password)
    cookies = AutoVagas.Crawler.Auth.get_cookies(session_data)

    new_state = Map.put(state, source, %{
      session: session_data,
      cookies: cookies,
      inserted_at: DateTime.utc_now()
    })

    {:reply, :ok, new_state}
  end

  def handle_call({:get_cookies, source}, _from, state) do
    result = case Map.get(state, source) do
      nil -> []
      session -> Map.get(session, :cookies, [])
    end

    {:reply, result, state}
  end

  def handle_call({:active?, source}, _from, state) do
    {:reply, Map.has_key?(state, source), state}
  end

  def handle_call({:delete_session, source}, _from, state) do
    case Map.get(state, source) do
      nil ->
        {:reply, nil, state}

      %{session: session_data} ->
        AutoVagas.Crawler.Auth.end_session(session_data)
        {:reply, :ok, Map.delete(state, source)}
    end
  end

  def handle_call({:update_cookies, source, cookies}, _from, state) do
    new_state = case Map.get(state, source) do
      nil -> state
      session_data -> Map.put(state, source, %{session_data | cookies: cookies})
    end

    {:reply, :ok, new_state}
  end
end
