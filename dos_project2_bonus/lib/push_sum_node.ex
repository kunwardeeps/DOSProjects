defmodule PushSum.Node do
  use GenServer, restart: :transient

  @impl true
  def init(args) do
    [_numNodes, i, _s, _w, _warning_count, _topology, _pushsum_pid] = args
    GossipPushSum.Main.print("Process id:#{inspect(i)}, #{inspect(self())} initiated")
    {:ok, args}
  end

  @impl true
  def handle_call({:get_state}, _from, [numNodes, i, s, w, warning_count, topology, pushsum_pid]) do
    {:reply, [s,w], [numNodes, i, s, w, warning_count, topology, pushsum_pid]}
  end

  @impl true
  def handle_cast({:save_state, s1, w1}, [numNodes, i, s, w, warning_count, topology, pushsum_pid]) do
    new_warning_count = get_warning_count(s/w, s1/w1, warning_count)
    {:noreply, [numNodes, i, s1, w1, new_warning_count, topology, pushsum_pid]}
  end

  @impl true
  def handle_cast({:shutdown}, [numNodes, i, s, w, warning_count, topology, pushsum_pid]) do
    if (pushsum_pid != nil) do
      GossipPushSum.Main.print("Exiting pid #{inspect(pushsum_pid)}")
      Process.exit(pushsum_pid, :kill)
    end
    GossipPushSum.Registry.remove(i)
    {:stop, :normal, [numNodes, i, s, w, warning_count, topology, pushsum_pid]}
  end

  @impl true
  def handle_cast({:message, s1, w1}, [numNodes, i, s, w, warning_count, topology, pushsum_pid]) do
    cond do
      s == i ->
        GossipPushSum.Main.print("First message #{inspect{:message, s1, w1}} received for node: #{i}, #{inspect(self())} state = #{inspect([numNodes, i, s, w, warning_count, topology])}")
        neighbour_list = GossipPushSum.Registry.get_neighbour_list(i, topology, numNodes)
        if (Enum.empty?(neighbour_list) && (topology == "random_2d" || topology == "3d" || topology == "toroid")) do
          GossipPushSum.Main.print("No neighbours for #{i}")
          GossipPushSum.Registry.remove(i)
          {:stop, :normal, [numNodes, i, s, w, warning_count, topology, pushsum_pid]}
        else
          node_pid = self()
          pushsum_pid = spawn fn -> forward_message(i, numNodes, topology, neighbour_list, node_pid, 0) end
          Process.monitor(pushsum_pid)
          {:noreply, [numNodes, i, (s+s1)/2, (w+w1)/2, warning_count, topology, pushsum_pid]}
        end
      (warning_count > 3) ->
        GossipPushSum.Main.print("Message #{inspect{:message, s1, w1}} received for node: #{i}, #{inspect(self())} state = #{inspect([numNodes, i, s, w, warning_count, topology])}")
        GossipPushSum.Registry.remove(i)
        Process.exit(pushsum_pid, :kill)
        Process.sleep(200) #Wait for pushsum_pid to stop
        {:stop, :normal, [numNodes, i, s, w, warning_count, topology, pushsum_pid]}
      true ->
        GossipPushSum.Main.print("Message #{inspect{:message, s1, w1}} received for node: #{i}, #{inspect(self())} state = #{inspect([numNodes, i, s, w, warning_count, topology])}")
        new_s = (s1 + s)/2
        new_w = (w1 + w)/2
        new_warning_count = get_warning_count(s/w, new_s/new_w, warning_count)
        {:noreply, [numNodes, i, new_s, new_w, new_warning_count, topology, pushsum_pid]}
    end
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, _pid, _reason}, [numNodes, i, s, w, warning_count, topology, pushsum_pid]) do
    GossipPushSum.Registry.remove(i)
    if (pushsum_pid != nil) do
      Process.exit(pushsum_pid, :kill)
    end
    {:stop, :normal, [numNodes, i, s, w, warning_count, topology, pushsum_pid]}
  end

  def get_warning_count(r1, r2, warning_count) do
    if (abs(r1-r2) < 1.0e-10) do
      warning_count + 1
    else
      warning_count
    end
  end

  @impl true
  def terminate(_reason, [_numNodes, i, _s, _w, _warning_count, _topology, _neighbour_list]) do
    GossipPushSum.Main.print("Limit reached for node: #{i}, #{inspect(self())} so shutting down...")
  end

  def forward_message(i, numNodes, topology, neighbour_list, node_pid, nil_count) do
    next_node = GossipPushSum.Registry.get_next_node(i, topology, numNodes, neighbour_list)
    if (next_node != nil) do
      GossipPushSum.Main.print("Message forwarding to pid: #{inspect(next_node)} from #{i}")
      response = GenServer.call(node_pid, {:get_state})
      [s,w] = response
      new_s = s/2
      new_w = w/2
      GenServer.cast(next_node, {:message, new_s, new_w})
      GenServer.cast(node_pid, {:save_state, new_s, new_w})
      forward_message(i, numNodes, topology, neighbour_list, node_pid, 0)
    else
      if (nil_count < 50) do
        forward_message(i, numNodes, topology, neighbour_list, node_pid, nil_count+1)
      else
        GossipPushSum.Main.print("nil_count > 50 for node #{i}")
        Process.exit(self(), :kill)
      end
    end
  end

end
