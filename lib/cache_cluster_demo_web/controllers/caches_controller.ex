defmodule CacheClusterDemoWeb.CachesController do
  use CacheClusterDemoWeb, :controller

  def index(conn, _params) do
    response = %{
      cache_a_values: inspect(MyCache.CacheA.all()),
      cache_b_values: inspect(MyCache.CacheB.all())
    }

    json(conn, response)
  end
end
