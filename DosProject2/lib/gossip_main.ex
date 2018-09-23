defmodule GossipMain do
  def start(numNodes) do
    first_node = :rand.uniform(numNodes)
    GossipPushSumMain.print("Gossip starting from #{first_node}")
    GenServer.call(get_node_pid(first_node), {:gossip, "Fuch my life"})
  end

  def get_node_pid(id) do
    [{pid, _}] =  Registry.lookup(Node.Registry, id)
    pid
  end
end
