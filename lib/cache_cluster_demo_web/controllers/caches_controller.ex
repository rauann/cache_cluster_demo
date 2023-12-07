defmodule CacheClusterDemoWeb.CachesController do
  use CacheClusterDemoWeb, :controller

  def index(conn, _params) do
    response = %{
      cache_a_values: MyCache.CacheA.get_all(~w(one two three)a),
      cache_b_values: inspect(MyCache.CacheB.all(nil, return: {:key, :value}))
    }

    json(conn, response)
  end
end
