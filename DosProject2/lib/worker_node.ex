defmodule Network.Node do
  use GenServer

  @impl true
  def init(args) do
    [i, _, _] = args
    GossipPushSumMain.print("Process id:#{inspect(i)} initiated")
    {:ok, args}
  end

  @impl true
  def handle_call({:gossip, message}, _from, [i, numNodes, count]) do
    GossipPushSumMain.print("Gossip received for node: #{i}, last count = #{count}")
    {:reply, count, [i, numNodes, count+1]}
  end

end
