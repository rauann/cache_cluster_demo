defmodule CacheClusterDemoWeb.HealthCheckController do
  use CacheClusterDemoWeb, :controller

  def index(conn, _params) do
    response = %{
      status: "ok",
      timestamp: DateTime.to_unix(DateTime.utc_now())
    }

    json(conn, response)
  end
end
