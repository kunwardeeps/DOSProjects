defmodule Chord.Node do
  use GenServer

  @impl true
  def init(args) do
    [node_key, node_name, _finger_table, _num_hops, _request_counter, _predecessor, _successor] = args
    Chord.Main.print("Node: #{inspect(node_key)} (name: #{inspect(node_name)}, pid: #{inspect(self())}) initiated!")
    {:ok, args}
  end

end
