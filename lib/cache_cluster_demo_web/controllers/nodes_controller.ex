defmodule CacheClusterDemoWeb.NodesController do
  use CacheClusterDemoWeb, :controller

  def index(conn, _params) do
    response = %{
      node: Node.self(),
      nodes: Node.list(),
      timestamp: DateTime.to_unix(DateTime.utc_now())
    }

    json(conn, response)
  end
end
