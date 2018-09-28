defmodule GossipMain do
  use GenServer

  @impl true
  def init([numNodes, exit_count, main_pid, topology]) do
    init_nodes(numNodes, 1, topology)
    {:ok, [numNodes, exit_count, main_pid, topology]}
  end

  @impl true
  def handle_call(_request, _from, [numNodes, exit_count, main_pid, topology]) do
    start(numNodes)
    {:reply, [], [numNodes, exit_count, main_pid, topology]}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, [numNodes, exit_count, main_pid]) do
    if (exit_count+1 < numNodes) do
      GossipPushSum.Main.print "Process #{inspect(pid)} down, exit count: #{exit_count+1}!"
      {:noreply, [numNodes, exit_count+1, main_pid]}
    else
      GossipPushSum.Main.print("exit count: #{exit_count+1}, so converging...")
      send(main_pid, {:converge, "Converged!"})
      {:noreply, [numNodes, exit_count+1, main_pid]}
    end
  end

  def start(numNodes) do
    first_node = GossipPushSum.Registry.get(:rand.uniform(numNodes))
    GossipPushSum.Main.print("Gossip starting from #{inspect(first_node)}")
    GenServer.cast(first_node, {:gossip, "Fuch my life"})
  end

  def init_nodes(numNodes, i, topology) do
    if (i <= numNodes) do
      {:ok, pid} = GenServer.start_link(Gossip.Node, [i, numNodes, 0, topology])
      GossipPushSum.Registry.put(i, pid)
      Process.monitor(pid)
      init_nodes(numNodes, i+1, topology)
    end
  end
end
