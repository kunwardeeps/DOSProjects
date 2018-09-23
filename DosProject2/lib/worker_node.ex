defmodule Network.Node do
  use GenServer
  @maxGossips 10

  @impl true
  def init(args) do
    [i, _, _] = args
    GossipPushSumMain.print("Process id:#{inspect(i)} initiated")
    {:ok, args}
  end

  @impl true
  def handle_cast({:gossip, message}, [i, numNodes, count]) do
    if (count <= @maxGossips) do
      GossipPushSumMain.print("Gossip received for node: #{i}, last count = #{count}")
      forward_gossip(numNodes,message)
      {:noreply, [i, numNodes, count+1]}
    else
      GossipPushSumMain.print("Limit reached for node: #{i}")
      {:noreply, [i, numNodes, count]}
    end

  end

  defp forward_gossip(numNodes, message) do
    next_node = :rand.uniform(numNodes)
    GossipPushSumMain.print("Gossip forwarding to #{next_node}")
    GenServer.cast(GossipMain.get_node_pid(next_node), {:gossip, message})
  end

end
