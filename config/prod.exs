import Config

# Do not print debug messages in production
config :logger, level: :info

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.

config :cache_cluster_demo, CacheClusterDemoWeb.Endpoint, check_origin: ["//*.amazonaws.com"]

config :libcluster,
  topologies: [
    ecs: [
      strategy: Cluster.Strategy.DNSPoll,
      config: [
        polling_interval: 5_000,
        query: "development-cache-cluster-demo-513612322.eu-north-1.elb.amazonaws.com",
        node_basename: "cache_cluster_demo"
      ]
    ]
  ]
