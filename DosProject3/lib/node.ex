defmodule Chord.Node do
  use GenServer

  @impl true
  def init(args) do
    [node_key, node_name, num_requests, num_nodes, _finger_table, _num_hops, _request_counter, _predecessor, _successor] = args
    Chord.Main.print("Node: #{inspect(node_key)} (name: #{inspect(node_name)}, pid: #{inspect(self())}) initiated!")
    {:ok, args}
  end

  @impl true
  def handle_call({:update_state, predecessor, successor, finger_table}, _from, [node_key, node_name, num_requests, num_nodes, _finger_table, num_hops, request_counter, _predecessor, _successor]) do
    Chord.Main.print("Updated state for Node: #{node_key}, state:#{inspect([node_key, node_name, num_requests, num_nodes, finger_table, num_hops, request_counter, predecessor, successor])}")
    {:reply, :ok, [node_key, node_name, num_requests, num_nodes, finger_table, num_hops, request_counter, predecessor, successor]}
  end

  @impl true
  def handle_cast({:trigger}, [node_key, node_name, num_requests, num_nodes, finger_table, num_hops, request_counter, predecessor, successor]) do
    #TODO call stabilize and fix_fingers
  end

  @impl true
  def handle_cast({:forward, destination_key, current_hop_count}, [node_key, node_name, num_requests, num_nodes, finger_table, num_hops, request_counter, predecessor, successor]) do

    Chord.Main.print("Received message in #{node_key} with state #{inspect([node_key, node_name, num_requests, num_nodes, finger_table, num_hops, request_counter, predecessor, successor])}, final destination: #{destination_key}")
    [_,_, pred_node] = predecessor
    if (destination_bet_current_predecessor(node_key, pred_node, destination_key)) do
      Chord.Main.print("Saving hops as #{num_hops+current_hop_count} in #{node_key}")
      {:noreply, [node_key, node_name, num_requests, num_nodes, finger_table, num_hops+current_hop_count, request_counter, predecessor, successor]}
    else
      forward_message(finger_table, destination_key, node_key, current_hop_count+1)
      {:noreply, [node_key, node_name, num_requests, num_nodes, finger_table, num_hops, request_counter, predecessor, successor]}
    end
  end

  @impl true
  def handle_cast({:send_random, m}, [node_key, node_name, num_requests, num_nodes, finger_table, num_hops, request_counter, predecessor, successor]) do
    pid = spawn fn -> send_messages(finger_table, node_key, num_requests, m, 0) end
    Process.monitor(pid)
    {:noreply, [node_key, node_name, num_requests, num_nodes, finger_table, num_hops, request_counter, predecessor, successor]}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, _pid, _reason}, [node_key, node_name, num_requests, num_nodes, finger_table, num_hops, request_counter, predecessor, successor]) do
    Chord.Registry.remove(node_key)
    {:stop, :normal, [node_key, node_name, num_requests, num_nodes, finger_table, num_hops, request_counter, predecessor, successor]}
  end

  def send_messages(finger_table, node_key, num_requests, m, i) do
    if (i< num_requests) do
      random_key = :rand.uniform(trunc(:math.pow(2, m)))
      Chord.Main.print("Sending message to #{random_key} from #{node_key}, finger table: #{inspect(finger_table)}")
      forward_message(finger_table, random_key, node_key, 1)
      send_messages(finger_table, node_key, num_requests, m, i+1)
    else
      Process.sleep(200)
      Process.exit(self(), :kill)
    end
  end

  def destination_bet_current_predecessor(current_node, predecessor, destination) do
    cond do
      (current_node > predecessor and (destination > predecessor and destination <= current_node)) -> true
      (current_node < predecessor and (destination > predecessor or destination < current_node)) -> true
      true -> false
    end
  end

  def forward_message(finger_table, destination_key, node_key, current_hop_count) do
    successor = Chord.Registry.get_successor(node_key)
    [pid, succ_node_name, succ_node_key] = successor
    if (destination_bet_current_successor(node_key, succ_node_key, destination_key)) do
      Chord.Main.print("Forwarding to successor #{inspect([pid, succ_node_name, succ_node_key])} from #{node_key}")
      GenServer.cast(pid, {:forward, destination_key, current_hop_count})
    else
      forward_message_closest_preceding_node(finger_table, destination_key, node_key, current_hop_count)
    end
  end

  def destination_bet_current_successor(current_node, successor, destination) do
    cond do
      (successor > current_node and (destination > current_node and destination <= successor)) -> true
      (successor < current_node and (destination > current_node or destination <= successor)) -> true
      true -> false
    end
  end

  def forward_message_closest_preceding_node(finger_table, destination_key, node_key, current_hop_count) do

    closest_preceding_node = get_closest_preceding_node(finger_table, destination_key, node_key)
    node = Chord.Registry.get(closest_preceding_node)
    if (node != nil) do
      [pid, next_node_name, next_node_key] = node
      Chord.Main.print("Forwarding to closest preceding node: #{inspect([pid, next_node_name, next_node_key])} from #{node_key}")
      GenServer.cast(pid, {:forward, destination_key, current_hop_count})
    end
  end

  def get_closest_preceding_node(finger_table, destination_key, node_key) do
    loop_closest_preceding_node(finger_table, destination_key, node_key, 0, length(finger_table))
  end

  def loop_closest_preceding_node(finger_table, destination_key, node_key, i, l) do
    current = Enum.at(finger_table, i)
    if (i == l-1) do
      current
    else
      next = Enum.at(finger_table, i+1)
      if (next >= current) do
        if (destination_key >= current and destination_key < next) do
          current
        else
          loop_closest_preceding_node(finger_table, destination_key, node_key, i+1, l)
        end
      else
        if (destination_key >= current or destination_key < next) do
          current
        else
          loop_closest_preceding_node(finger_table, destination_key, node_key, i+1, l)
        end
      end
    end
  end
end
