defmodule CacheClusterDemoWeb.NodesController do
  use CacheClusterDemoWeb, :controller

  def index(conn, _params) do
    dns_ips =
      Cluster.Strategy.DNSPoll.lookup_all_ips(
        ~c"dev-cache-cluster-demo.dev-cache-cluster-demo.local"
      )

    response = %{
      lib_cluster_dns_ips: inspect(dns_ips),
      dns_cluster_dns_nodes: inspect(DNSCluster.Resolver.list_nodes()),
      node: Node.self(),
      nodes: Node.list(),
      timestamp: DateTime.to_unix(DateTime.utc_now())
    }

    json(conn, response)
  end
end
