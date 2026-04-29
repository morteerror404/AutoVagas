defmodule AutoVagas.Mnesia.Schema do
  @moduledoc """
  Gerencia o esquema Mnesia para o sistema AutoVagas.
  Cria e mantém tabelas para múltiplos crawlers simultâneos.
  """

  require Logger

  @doc """
  Inicializa o esquema Mnesia com todas as tabelas necessárias.
  Deve ser chamado na inicialização da aplicação.
  """
  def init do
    :mnesia.start()

    # Create schema only if it doesn't exist
    case :mnesia.create_schema([node()]) do
      :ok ->
        Logger.info("Mnesia schema created")

      {:error, {:already_exists, _}} ->
        Logger.debug("Mnesia schema already exists")

      {:error, reason} ->
        Logger.warning("Mnesia schema creation failed: #{inspect(reason)} - continuing anyway")
    end

    create_tables()
    :ok
  end

  def create_tables do
    create_search_table()
    create_jobs_table()
    create_notifications_table()
    create_user_sessions_table()
  end

  @doc """
  Tabela de configurações de busca.
  Cada busca tem um ID único e pode ter parâmetros diferentes.
  """
  def create_search_table do
    opts = [
      attributes: [:id, :keywords, :sources, :location, :filters, :status, :created_at, :updated_at],
      type: :set
    ]

    opts = add_storage_opt(opts)
    :mnesia.create_table(:searches, opts)
    |> handle_result("searches")
  end

  @doc """
  Tabela de vagas encontradas.
  Cada vaga está associada a uma busca específica.
  """
  def create_jobs_table do
    opts = [
      attributes: [:id, :search_id, :external_id, :source, :title, :company, :location, :url, :status, :applied_at, :created_at],
      type: :bag
    ]

    opts = add_storage_opt(opts)
    :mnesia.create_table(:jobs, opts)
    |> handle_result("jobs")
  end

  @doc """
  Tabela de notificações pendentes.
  Usada para alertas via WhatsApp, Telegram, Discord.
  """
  def create_notifications_table do
    opts = [
      attributes: [:id, :type, :channel, :recipient, :content, :status, :created_at, :sent_at],
      type: :set
    ]

    opts = add_storage_opt(opts)
    :mnesia.create_table(:notifications, opts)
    |> handle_result("notifications")
  end

  @doc """
  Tabela de sessões do usuário.
  Armazena estado da sessão e configurações temporárias.
  """
  def create_user_sessions_table do
    opts = [
      attributes: [:session_id, :user_info, :current_searches, :preferences, :created_at, :expires_at],
      type: :set
    ]

    opts = add_storage_opt(opts)
    :mnesia.create_table(:user_sessions, opts)
    |> handle_result("user_sessions")
  end

  @doc """
  Aguarda todas as tabelas estarem disponíveis.
  """
  def wait_for_tables do
    tables = [:searches, :jobs, :notifications, :user_sessions]

    case :mnesia.wait_for_tables(tables, 10_000) do
      :ok -> :ok
      {:timeout, bad_tables} ->
        Logger.error("Timeout waiting for tables: #{inspect(bad_tables)}")
        :error
    end
  end

  defp handle_result({:atomic, :ok}, table) do
    Logger.info("Table #{table} created")
    :ok
  end

  defp handle_result({:aborted, {:already_exists, _}}, table) do
    Logger.debug("Table #{table} already exists")
    :already_exists
  end

  defp handle_result({:aborted, reason}, table) do
    Logger.error("Failed to create table #{table}: #{inspect(reason)}")
    {:error, reason}
  end

  defp add_storage_opt(opts) do
    storage_type = if node() == :nonode@nohost do
      :ram_copies
    else
      :disc_copies
    end

    Keyword.put(opts, storage_type, [node()])
  end
end
