defmodule Gossip.Node do
  use GenServer, restart: :transient
  @maxGossips 10

  @impl true
  def init(args) do
    [i, _, _, _, _] = args
    GossipPushSum.Main.print("Process id:#{inspect(i)} initiated")
    {:ok, args}
  end

  @impl true
  def handle_cast({:gossip, message}, [i, numNodes, count, topology, gossip_pid]) do
    cond do
      count == 0 ->
        GossipPushSum.Main.print("First gossip received for node: #{i}, current count = #{count+1}")
        neighbour_list = GossipPushSum.Registry.get_neighbour_list(i, topology, numNodes)
        if (Enum.empty?(neighbour_list) && (topology == "random_2d" || topology == "3d")) do
          GossipPushSum.Main.print("No neighbours for #{i}")
          GossipPushSum.Registry.remove(i)
          {:stop, :normal, [i, numNodes, count+1, topology, gossip_pid]}
        else
          gossip_pid = spawn fn -> forward_gossip(i, message, topology, numNodes, neighbour_list, 0, gossip_pid) end
          Process.monitor(gossip_pid)
          {:noreply, [i, numNodes, count+1, topology, gossip_pid]}
        end
      (count+1 >= @maxGossips) ->
        GossipPushSum.Main.print("Gossip received for node: #{i}, current count = #{count+1}")
        GossipPushSum.Registry.remove(i)
        Process.exit(gossip_pid, :kill)
        {:stop, :normal, [i, numNodes, count+1, topology, gossip_pid]}
      true ->
        GossipPushSum.Main.print("Gossip received for node: #{i}, current count = #{count+1}")
        {:noreply, [i, numNodes, count+1, topology, gossip_pid]}
    end
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, _pid, _reason}, [i, numNodes, count, topology, gossip_pid]) do
    GossipPushSum.Registry.remove(i)
    Process.exit(gossip_pid, :kill)
    {:stop, :normal, [i, numNodes, count+1, topology, gossip_pid]}
  end

  @impl true
  def terminate(_reason, [i, _numNodes, _count, _topology, _gossip_pid]) do
    GossipPushSum.Main.print("Limit reached for node: #{i} so shutting down...")
  end

  defp forward_gossip(i, message, topology, numNodes, neighbour_list, nil_count, gossip_pid) do
    next_node = GossipPushSum.Registry.get_next_node(i, topology, numNodes, neighbour_list)
    if (next_node != nil) do
      GossipPushSum.Main.print("Gossip forwarding to pid: #{inspect(next_node)} from #{i}")
      GenServer.cast(next_node, {:gossip, message})
      Process.sleep(100)
      forward_gossip(i, message, topology, numNodes, neighbour_list, 0, gossip_pid)
    else
      if (nil_count < 50) do
        forward_gossip(i, message, topology, numNodes, neighbour_list, nil_count+1, gossip_pid)
      else
        IO.inspect("nil_count > 50 for node #{i}")
        Process.exit(self(), :kill)
      end
    end
  end

end
