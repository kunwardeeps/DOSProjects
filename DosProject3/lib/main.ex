defmodule Chord.Main do
  @moduledoc """
  Documentation for DosProject3.
  """
  @debug true

  def start(num_nodes, num_requests, failure_nodes \\ 0) do
    init_registry()
    print("Registry intialized!")
    start_ring(num_nodes, num_requests)
    wait_for_exit()
  end

  def start_ring(num_nodes, num_requests) do
    {:ok, pid} = GenServer.start_link(Chord.Ring.Main, [num_nodes, num_requests, 0, self()])
    GenServer.call(pid, {}, 100000)
  end

  def wait_for_exit() do
    receive do
      {:converge, msg} -> print(msg)
    after
      20_000 -> print("Couldn't exit even after 20s!")
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
