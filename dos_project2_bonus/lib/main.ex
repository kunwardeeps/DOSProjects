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
  def start(numNodes, topology \\ "full_network", algorithm \\ "gossip", start_nodes \\ 1, fail_nodes \\0) do
    init_registry()
    print("Registry intialized!")
    case algorithm do
      @input_gossip -> start_algo_main(GossipMain, numNodes, 1, start_nodes, topology)
      @input_push_sum -> start_algo_main(PushSumMain, numNodes, 1, start_nodes, topology)
    end
    if (fail_nodes > 0) do
      simulate_fail_conditions(fail_nodes, numNodes, 0)
    end
    wait_for_convergence()
  end

  def wait_for_convergence() do
    receive do
      {:converge, msg} -> IO.puts(msg)
    after
      20_000 -> IO.puts("Couldn't converge even after 10s!")
    end

  end

  def start_algo_main(module, numNodes, i, start_nodes, topology) do
    if (i <= start_nodes) do
      {:ok, pid} = GenServer.start_link(module, [numNodes, 0, self(), topology])
      GenServer.call(pid, [])
      start_algo_main(module, numNodes, i+1, start_nodes, topology)
    end
  end

  def simulate_fail_conditions(fail_nodes, numNodes, counter) do
    if (counter < fail_nodes) do
      node_id = :rand.uniform(numNodes)
      value = GossipPushSum.Registry.get(node_id)
      if (value != nil)do
        [_,_,_,node_pid,_] = GossipPushSum.Registry.get(node_id)
        IO.puts("Trying to kill #{node_id}, #{inspect(node_pid)}")
        GenServer.cast(node_pid, {:shutdown})
      else
        IO.puts("Process #{node_id}, #{inspect(value)} not registered!")
      end
      simulate_fail_conditions(fail_nodes, numNodes, counter+1)
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
