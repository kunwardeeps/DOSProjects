defmodule Chord.Ring.Main do
  use GenServer

  @m 8

  @impl true
  def init(args) do
    Chord.Main.print("Ring Initiated, state: #{inspect(args)}")
    {:ok, args}
  end

  @impl true
  def handle_call(_request, _from, [num_nodes, num_requests, exit_count, main_pid]) do
    init_nodes(num_nodes, num_requests, 1)
    init_node_states()
    send_random_nodes(Chord.Registry.get_all_values())
    {:reply, [], [num_nodes, num_requests, exit_count, main_pid]}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, [num_nodes, num_requests, exit_count, main_pid]) do
    Chord.Main.print("Exit count: #{inspect(exit_count)}")
    if (exit_count+1 < num_nodes) do
      Chord.Main.print "Node #{inspect(pid)} down, exit count: #{exit_count+1}!"
      {:noreply, [num_nodes, num_requests, exit_count+1, main_pid]}
    else
      Chord.Main.print("exit count: #{exit_count+1}, so exiting...")
      send(main_pid, {:converge, "All Nodes exited!"})
      {:noreply, [num_nodes, num_requests, exit_count+1, main_pid]}
    end
  end

  def send_random_nodes([]) do end

  def send_random_nodes([head|tail]) do
    [pid, _node_name, _node_key] = head
    GenServer.cast(pid, {:send_random, @m})
    send_random_nodes(tail)
  end

  def init_node_states() do
    nodes = Chord.Registry.get_all_values()
    Enum.each nodes, fn [pid, _node_name, node_key] ->
      GenServer.call(pid, {:update_state, Chord.Registry.get_predecessor(node_key),
        Chord.Registry.get_successor(node_key),
        Chord.Registry.get_finger_table(node_key, @m)})
    end
  end

  def init_nodes(num_nodes, num_requests, i) do
    if (i <= num_nodes) do

      {node_name, node_key} = get_node_key(i)
      {:ok, pid} = GenServer.start_link(Chord.Node, [node_key, node_name, num_requests, num_nodes, [], 0, 0, nil, nil])

      Chord.Registry.put(node_key, [pid, node_name, node_key])

      Process.monitor(pid)
      init_nodes(num_nodes, num_requests, i+1)
    end
  end

  def get_node_key(i) do
    node_name = Chord.HashModule.generate_random_string(5)<>"_"<>Integer.to_string(i)
    node_key = Chord.HashModule.get_node_id(node_name, @m)
    if (Chord.Registry.exists?(node_key)) do
      get_node_key(i)
    else
      {node_name, node_key}
    end
  end
end
