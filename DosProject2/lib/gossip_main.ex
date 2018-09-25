defmodule GossipMain do
  use GenServer

  @impl true
  def init([numNodes, exit_count, main_pid]) do
    init_nodes(numNodes, 1)
    {:ok, [numNodes, exit_count, main_pid]}
  end

  @impl true
  def handle_call(_request, _from, [numNodes, exit_count, main_pid]) do
    start(numNodes)
    {:reply, [], [numNodes, exit_count, main_pid]}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, [numNodes, exit_count, main_pid]) do
    if (exit_count+1 < numNodes) do
      IO.inspect "Process #{inspect(pid)} down, exit count: #{exit_count+1}!"
      {:noreply, [numNodes, exit_count+1, main_pid]}
    else
      IO.inspect("exit count: #{exit_count+1}, so converging...")
      send(main_pid, {:converge, "Converged!"})
      {:noreply, [numNodes, exit_count+1, main_pid]}
    end
  end

  def init_nodes(numNodes, i) do
    if (i <= numNodes) do
      {:ok, pid} = GenServer.start_link(GossipPushSum.Node, [i, numNodes, 0])
      GossipPushSum.Registry.put(i, pid)
      Process.monitor(pid)
      init_nodes(numNodes, i+1)
    end
  end

  def start(numNodes) do
    first_node = GossipPushSum.Registry.get(:rand.uniform(numNodes))
    GossipPushSum.Main.print("Gossip starting from #{inspect(first_node)}")
    GenServer.cast(first_node, {:gossip, "Fuch my life"})
  end
end
