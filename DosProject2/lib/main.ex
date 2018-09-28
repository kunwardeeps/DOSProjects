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
  def start(numNodes, _topology \\ "a", algorithm \\ "gossip", start_nodes \\ 2) do
    init_registry()
    print("Registry intialized!")
    case algorithm do
      @input_gossip -> start_algo_main(GossipMain, numNodes, 1, start_nodes)
      @input_push_sum -> start_algo_main(PushSumMain, numNodes, 1, start_nodes)
    end
    wait_for_convergence()
  end

  def wait_for_convergence() do
    receive do
      {:converge, msg} -> IO.puts(msg)
    after
      20_000 -> IO.puts("Couldn't converge even after 20s!")
    end

  end

  def start_algo_main(module, numNodes, i, start_nodes) do
    if (i <= start_nodes) do
      {:ok, pid} = GenServer.start_link(module, [numNodes, 0, self()])
      GenServer.call(pid, {})
      start_algo_main(module, numNodes, i+1, start_nodes)
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
