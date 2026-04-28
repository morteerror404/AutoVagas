defmodule AutoVagas.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    AutoVagas.Mnesia.Schema.init()
    AutoVagas.Mnesia.Schema.wait_for_tables()
    AutoVagas.Experience.initialize()

    children = [
      AutoVagasWeb.Telemetry,
      # AutoVagas.Repo,
      {DNSCluster, query: Application.get_env(:auto_vagas, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: AutoVagas.PubSub},
      AutoVagasWeb.Endpoint,
      {AutoVagas.Crawler.AuthSession, []},
      {AutoVagas.Crawler.WorkerSupervisor, []},
      {AutoVagas.Crawler.JobsCache, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AutoVagas.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AutoVagasWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
