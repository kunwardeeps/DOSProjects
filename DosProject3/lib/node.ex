defmodule Chord.Node do
  use GenServer

  @impl true
  def init(args) do
    [node_key, node_name, num_requests, _finger_table, _num_hops, _request_counter, _predecessor, _successor] = args
    Chord.Main.print("Node: #{inspect(node_key)} (name: #{inspect(node_name)}, pid: #{inspect(self())}) initiated!")
    {:ok, args}
  end

  @impl true
  def handle_call({:update_state, predecessor, successor, finger_table}, _from, [node_key, node_name, num_requests, _finger_table, num_hops, request_counter, _predecessor, _successor]) do
    Chord.Main.print("Updated state for Node: #{node_key}, state:#{inspect([node_key, node_name, num_requests, finger_table, num_hops, request_counter, predecessor, successor])}")
    {:reply, :ok, [node_key, node_name, num_requests, finger_table, num_hops, request_counter, predecessor, successor]}
  end

end
