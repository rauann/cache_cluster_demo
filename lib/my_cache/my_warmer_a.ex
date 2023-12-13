defmodule MyCache.MyWarmerA do
  use GenServer

  require Logger

  @schedule_interval 3_600_000

  def start_link(opts \\ []), do: GenServer.start_link(__MODULE__, opts)

  @impl true
  def init(state) do
    Logger.info("Initializing MyWarmerA on #{inspect(Node.self())}")

    schedule_work()

    {:ok, state}
  end

  @impl true
  def handle_info(:work, state) do
    node_name = Node.self()

    result =
      Enum.map(state, fn s ->
        MyCache.CacheA.get_and_update(s, fn current_value ->
          {current_value, "Node: #{node_name}"}
        end)
      end)

    Logger.info("Warming up MyCacheA with #{inspect(result)}")

    schedule_work()

    {:noreply, state}
  end

  defp schedule_work, do: Process.send_after(self(), :work, @schedule_interval)
end
