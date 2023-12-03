defmodule CacheClusterDemoWeb.Router do
  use CacheClusterDemoWeb, :router

  import Phoenix.LiveDashboard.Router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", CacheClusterDemoWeb do
    pipe_through :api
  end

  scope "/" do
    pipe_through [:fetch_session, :protect_from_forgery]

    get "/", CacheClusterDemoWeb.NodesController, :index
    get "/healthcheck", CacheClusterDemoWeb.HealthCheckController, :index

    live_dashboard "/dashboard", metrics: CacheClusterDemo.Telemetry
  end
end
