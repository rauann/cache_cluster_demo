defmodule MyCache.Warmer do
  require Logger
  use Cachex.Warmer

  def interval, do: :timer.seconds(10)

  def execute(state) do
    result =
      if Node.self() == :"b@rauans-MacBook-Pro" do
        Enum.map(state, fn s ->
          {s, inspect(Node.self())}
        end)
      else
        []
      end

    Logger.info("Warming up cache with #{inspect(result)}")

    {:ok, result}
  end
end
