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
    print("Registry intialized!")
    case algorithm do
      @input_gossip -> start_gossip_main(numNodes)
    end
  end

  def start_gossip_main(numNodes) do
    {:ok, pid} = GenServer.start_link(GossipMain, [numNodes, 0], [])
    GenServer.call(pid, {})
  end

  def init_registry() do
    Registry.start_link(keys: :unique, name: Node.Registry)
  end

  def print(msg) do
    if @debug do
      IO.inspect(msg)
    end
  end
end
