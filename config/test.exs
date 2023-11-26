import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :cache_cluster_demo, CacheClusterDemoWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "THbcjBQjrZKJuWOpX6IyvC0lcIkvgNbQNj+2CJSMI0FDMB55jkBY8YcVF7jNWUFU",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
