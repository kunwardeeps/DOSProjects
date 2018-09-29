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
        gossip_pid = spawn fn -> forward_gossip(i, message, topology) end
        {:noreply, [i, numNodes, count+1, topology, gossip_pid]}
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
  def terminate(_reason, [i, _numNodes, _count, _topology, _gossip_pid]) do
    GossipPushSum.Main.print("Limit reached for node: #{i} so shutting down...")
  end

  defp forward_gossip(i, message, topology) do
    next_node = GossipPushSum.Registry.get_next_node(i, topology)
    GossipPushSum.Main.print("Gossip forwarding to pid: #{inspect(next_node)} from #{i}")
    GenServer.cast(next_node, {:gossip, message})
    forward_gossip(i, message, topology)
  end

end
