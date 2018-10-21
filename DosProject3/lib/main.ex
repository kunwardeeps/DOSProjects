defmodule Chord.Main do
  @moduledoc """
  Documentation for DosProject3.
  """
  @debug false

  def start(num_nodes, num_requests, failure_nodes \\ 0) do
    init_registry()
    print("Registry intialized!")
    start_ring(num_nodes, num_requests, failure_nodes)
    if (failure_nodes > 0) do
      simulate_fail_conditions(failure_nodes, num_nodes, 0)
    end
    wait_for_exit(num_nodes, num_requests)
  end

  def simulate_fail_conditions(fail_nodes, numNodes, counter) do
    if (counter < fail_nodes) do
      [node_pid, _node_name, node_key] = Enum.random(Chord.Registry.get_all_values())
      IO.puts("Trying to kill #{node_key}, #{inspect(node_pid)}")
      GenServer.cast(node_pid, {:shutdown})
      simulate_fail_conditions(fail_nodes, numNodes, counter+1)
    end
  end

  def start_ring(num_nodes, num_requests, failure_nodes) do
    {:ok, pid} = GenServer.start_link(Chord.Ring.Main, [num_nodes, num_requests, 0, self(), 0], name: ChordMain)
    GenServer.call(pid, {:init, failure_nodes}, 100000)
  end

  def wait_for_exit(num_nodes, num_requests) do
    receive do
      {:converge, hops} -> IO.inspect("Average hops = #{hops/(num_nodes * num_requests)}")
    after
      60_000 -> print("Timeout after 60s!")
    end
  end

  def init_registry() do
    Chord.Registry.start_link()
  end

  def print(msg) do
    if @debug do
      IO.inspect(msg)
    end
  end
end
