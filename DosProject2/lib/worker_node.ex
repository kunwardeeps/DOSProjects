defmodule Network.Node do
  use GenServer, restart: :transient
  @maxGossips 10

  @impl true
  def init(args) do
    [i, _, _] = args
    GossipPushSumMain.print("Process id:#{inspect(i)} initiated")
    {:ok, args}
  end

  @impl true
  def handle_cast({:gossip, message}, [i, numNodes, count]) do
    GossipPushSumMain.print("Gossip received for node: #{i}, last count = #{count}")
    forward_gossip(numNodes,message)

    if (count+1 < @maxGossips) do
      {:noreply, [i, numNodes, count+1]}
    else
      {:stop, :normal, [i, numNodes, count+1]}
    end

  end

  @impl true
  def terminate(_reason, [i, _numNodes, _count]) do
    GossipPushSumMain.print("Limit reached for node: #{i} so shutting down...")
  end

  defp forward_gossip(numNodes, message) do
    next_node = :rand.uniform(numNodes)
    GossipPushSumMain.print("Gossip forwarding to #{next_node} with pid: #{inspect(GossipMain.get_node_pid(next_node))}")
    GenServer.cast(GossipMain.get_node_pid(next_node), {:gossip, message})
  end

end
