defmodule CacheClusterDemo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CacheClusterDemo.Telemetry,
      {DNSCluster,
       query: Application.get_env(:cache_cluster_demo, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: CacheClusterDemo.PubSub},
      CacheClusterDemoWeb.Endpoint,
      # {Cluster.Supervisor,
      #  [
      #    Application.get_env(:libcluster, :topologies, []),
      #    [name: CacheClusterDemo.ClusterSupervisor]
      #  ]},
      {MyCache.CacheA, []},
      {MyCache.CacheB, []}
    ]

    opts = [strategy: :one_for_one, name: CacheClusterDemo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CacheClusterDemoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
