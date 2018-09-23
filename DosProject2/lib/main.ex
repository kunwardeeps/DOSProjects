defmodule GossipPushSumMain do
  @moduledoc """
  Documentation for GossipPushSumImpl.
  """

  @input_gossip "gossip"
  @debug true

  @doc """
  Entry point
  """
  def start(numNodes, _topology, algorithm) do
    init_registry()
    init_nodes(numNodes, 1)
    GossipPushSumMain.print("#{inspect(numNodes)} nodes initiated!")
    case algorithm do
      @input_gossip -> GossipMain.start(numNodes)
    end
  end

  def init_registry() do
    Registry.start_link(keys: :unique, name: Node.Registry)
  end

  def init_nodes(numNodes, i) do
    if (i <= numNodes) do
      GenServer.start_link(Network.Node, [i, numNodes, 0], name: get_registry_node_name(i))
      init_nodes(numNodes, i+1)
    end
  end

  def get_registry_node_name(id) do
    {:via, Registry, {Node.Registry, id}}
  end

  def print(msg) do
    if @debug do
      IO.inspect(msg)
    end
  end
end
