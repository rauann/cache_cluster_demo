defmodule MyCache.Cache do
  use Nebulex.Cache,
    otp_app: :cache_cluster_demo,
    adapter: Nebulex.Adapters.Replicated
end
