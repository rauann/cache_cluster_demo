import Config

# Do not print debug messages in production
config :logger, level: :info

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.

config :cache_cluster_demo, CacheClusterDemoWeb.Endpoint, check_origin: ["//*.amazonaws.com"]
