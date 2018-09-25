defmodule GossipPushSum.Main do
  @moduledoc """
  Documentation for GossipPushSumImpl.
  """

  @input_gossip "gossip"
  @debug true

  @doc """
  Entry point
  """
  def start(numNodes, _topology \\ "a", algorithm \\ "gossip") do
    init_registry()
    print("Registry intialized!")
    case algorithm do
      @input_gossip -> start_gossip_main(numNodes)
    end
    wait_for_convergence()
  end

  def wait_for_convergence() do
    receive do
      {:converge, msg} -> IO.puts(msg)
    after
      100_000 -> IO.puts("Couldn't converge even after 10s!")
    end

  end

  def start_gossip_main(numNodes) do
    {:ok, pid} = GenServer.start_link(GossipMain, [numNodes, 0, self()])
    GenServer.call(pid, {})
  end

  def init_registry() do
    #Registry.start_link(keys: :unique, name: Node.Registry)
    GossipPushSum.Registry.start_link()
  end

  def print(msg) do
    if @debug do
      IO.inspect(msg)
    end
  end
end
