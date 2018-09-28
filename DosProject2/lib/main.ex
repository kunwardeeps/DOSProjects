defmodule GossipPushSum.Main do
  @moduledoc """
  Documentation for GossipPushSumImpl.
  """

  @input_gossip "gossip"
  @input_push_sum "push_sum"
  @debug true

  @doc """
  Entry point
  """
  def start(numNodes, topology \\ "a", algorithm \\ "gossip", start_nodes \\ 1) do
    init_registry()
    print("Registry intialized!")
    case algorithm do
      @input_gossip -> start_algo_main(GossipMain, numNodes, 1, start_nodes, topology)
      @input_push_sum -> start_algo_main(PushSumMain, numNodes, 1, start_nodes, topology)
    end
    wait_for_convergence()
  end

  def wait_for_convergence() do
    receive do
      {:converge, msg} -> IO.puts(msg)
    after
      10_000 -> IO.puts("Couldn't converge even after 10s!")
    end

  end

  def start_algo_main(module, numNodes, i, start_nodes, topology) do
    if (i <= start_nodes) do
      {:ok, pid} = GenServer.start_link(module, [numNodes, 0, self(), topology])
      GenServer.call(pid, {})
      start_algo_main(module, numNodes, i+1, start_nodes, topology)
    end
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
