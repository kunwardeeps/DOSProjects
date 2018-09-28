defmodule PushSumMain do
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
      GossipPushSum.Main.print "Process #{inspect(pid)} down, exit count: #{exit_count+1}!"
      {:noreply, [numNodes, exit_count+1, main_pid]}
    else
      GossipPushSum.Main.print("exit count: #{exit_count+1}, so converging...")
      send(main_pid, {:converge, "Converged!"})
      {:noreply, [numNodes, exit_count+1, main_pid]}
    end
  end

  def start(numNodes) do
    first_node_id = :rand.uniform(numNodes)
    first_node_pid = GossipPushSum.Registry.get(first_node_id)
    GossipPushSum.Main.print("Gossip starting from #{first_node_id}, pid #{inspect(first_node_pid)}")
    GenServer.cast(first_node_pid, {:message, 0, 0})
  end

  def init_nodes(numNodes, i) do
    if (i <= numNodes) do
      {:ok, pid} = GenServer.start_link(PushSum.Node, [numNodes, i, i, 1, 0])
      GossipPushSum.Registry.put(i, pid)
      Process.monitor(pid)
      init_nodes(numNodes, i+1)
    end
  end
end
