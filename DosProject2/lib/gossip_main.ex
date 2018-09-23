defmodule GossipMain do
  use GenServer

  @impl true
  def init([numNodes, exit_count]) do
    init_nodes(numNodes, 1)
    {:ok, [numNodes, exit_count]}
  end

  @impl true
  def handle_call(_request, _from, [numNodes, exit_count]) do
    start(numNodes)
    {:reply, [], [numNodes, exit_count]}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, [numNodes, exit_count]) do
    IO.inspect "Process #{inspect(pid)} down, exit count: #{exit_count+1}!"
    {:noreply, [numNodes, exit_count+1]}
  end

  def init_nodes(numNodes, i) do
    if (i <= numNodes) do
      {:ok, pid} = GenServer.start_link(Network.Node, [i, numNodes, 0], name: get_registry_node_name(i))
      Process.monitor(pid)
      init_nodes(numNodes, i+1)
    end
  end

  def get_registry_node_name(id) do
    {:via, Registry, {Node.Registry, id}}
  end

  def start(numNodes) do
    first_node = :rand.uniform(numNodes)
    GossipPushSumMain.print("Gossip starting from #{first_node}")
    GenServer.cast(get_node_pid(first_node), {:gossip, "Fuch my life"})
  end

  def get_node_pid(id) do
    case Registry.lookup(Node.Registry, id) do
      [{pid, _}] -> pid
      [] -> nil
    end
  end
end
