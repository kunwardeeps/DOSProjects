defmodule Chord.Ring.Main do
  use GenServer

  @m 16

  @impl true
  def init(args) do
    Chord.Main.print("Ring Initiated, state: #{inspect(args)}")
    {:ok, args}
  end

  @impl true
  def handle_call(_request, _from, [num_nodes, num_requests, exit_count, main_pid]) do
    init_nodes(num_nodes, num_requests, 1)
    init_node_states()
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

  def init_node_states() do

  end

  def init_nodes(num_nodes, num_requests, i) do
    if (i <= num_nodes) do
      node_name = "node"<>Integer.to_string(i)
      node_key = Chord.HashModule.get_node_id(node_name, @m)
      {:ok, pid} = GenServer.start_link(Chord.Node, [node_key, node_name, %{}, 0, 0, nil, nil])

      Chord.Registry.put(node_key, [pid, node_name])

      Process.monitor(pid)
      init_nodes(num_nodes, num_requests, i+1)
    end
  end

end
