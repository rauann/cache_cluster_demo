import Config

# Do not print debug messages in production
config :logger, level: :info

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.

config :cache_cluster_demo, CacheClusterDemoWeb.Endpoint, check_origin: ["//*.amazonaws.com"]

# DNSPoll strategy configuration.
# config :libcluster,
#   topologies: [
#     ecs: [
#       strategy: Cluster.Strategy.DNSPoll,
#       config: [
#         polling_interval: 5_000,
#         query: "dev-cache-cluster-demo.dev-cache-cluster-demo.local",
#         node_basename: "cache_cluster_demo"
#       ]
#     ]
#   ]
