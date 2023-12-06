defmodule MyCache.CacheA do
  use Nebulex.Cache,
    otp_app: :cache_cluster_demo,
    adapter: Nebulex.Adapters.Replicated
end

defmodule MyCache.CacheB do
  use Nebulex.Cache,
    otp_app: :cache_cluster_demo,
    adapter: Nebulex.Adapters.Replicated

  # primary_storage_adapter: Nebulex.Adapters.Cachex
end
