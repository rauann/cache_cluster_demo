defmodule CacheClusterDemo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  require Logger

  @impl true
  def start(_type, _args) do
    children = [
      CacheClusterDemo.Telemetry,
      {DNSCluster, query: get_dns_cluster_query()},
      {Phoenix.PubSub, name: CacheClusterDemo.PubSub},
      CacheClusterDemoWeb.Endpoint,
      {MyCache.CacheA, []},
      {MyCache.CacheB, []},
      {Task, fn -> debug_nodes() end}
    ]

    {:ok, _pid} =
      Singleton.start_child(MyCache.MyWarmerA, ~w(one two three)a, {:my_warmer, 1})

    opts = [strategy: :one_for_one, name: CacheClusterDemo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @spec get_dns_cluster_query() :: String.t() | :ignore
  defp get_dns_cluster_query,
    do: Application.get_env(:cache_cluster_demo, :dns_cluster_query, :ignore)

  defp debug_nodes() do
    Logger.info("RELEASE_COOKIE: #{System.get_env("RELEASE_COOKIE")}")
    Logger.info("DNS_CLUSTER_QUERY: #{get_dns_cluster_query()}")
    Logger.info("NODE: #{inspect(Node.self())}")
    Logger.info("NODES: #{inspect(Node.list())}")
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CacheClusterDemoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
