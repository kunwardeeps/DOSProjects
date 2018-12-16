defmodule Chord.Ring.Main do
  use GenServer

  @m 16

  @impl true
  def init(args) do
    Chord.Main.print("Ring Initiated, state: #{inspect(args)}")
    {:ok, args}
  end

  @impl true
  def handle_call({:update_hops, hops}, _from, [num_nodes, num_requests, exit_count, main_pid, total_hops]) do
    Chord.Main.print("Updating hops count to #{total_hops+hops}")
    {:reply, :ok, [num_nodes, num_requests, exit_count, main_pid, total_hops+hops]}
  end

  @impl true
  def handle_call({:init, failure_nodes}, _from, [num_nodes, num_requests, exit_count, main_pid, total_hops]) do
    init_nodes(num_nodes, num_requests, 1)
    init_node_states()
    init_stabilizer(failure_nodes)
    send_random_nodes(Chord.Registry.get_all_values())
    {:reply, [], [num_nodes, num_requests, exit_count, main_pid, total_hops]}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, [num_nodes, num_requests, exit_count, main_pid, total_hops]) do
    Chord.Main.print "Node #{inspect(pid)} down, exit count: #{exit_count+1}!"
    if (exit_count+1 < num_nodes) do

      {:noreply, [num_nodes, num_requests, exit_count+1, main_pid, total_hops]}
    else
      Chord.Main.print("exit count: #{exit_count+1}, so exiting...")
      if (Process.whereis(ChordStabilizer) != nil) do
        GenServer.call(ChordStabilizer, {:shutdown})
      end
      send(main_pid, {:converge, total_hops})
      {:noreply, [num_nodes, num_requests, exit_count+1, main_pid, total_hops]}
    end
  end

  def init_stabilizer(failure_nodes) do
    if (failure_nodes > 0) do
      GenServer.start_link(Chord.Stabilizer, [], name: ChordStabilizer)
      GenServer.cast(ChordStabilizer, {:trigger, @m})
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
      {:ok, pid} = GenServer.start_link(Chord.Node, [node_key, node_name, num_requests, num_nodes, [], 0, nil, nil])

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
