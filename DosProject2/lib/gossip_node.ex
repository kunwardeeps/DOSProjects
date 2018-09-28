defmodule Gossip.Node do
  use GenServer, restart: :transient
  @maxGossips 10

  @impl true
  def init(args) do
    [i, _, _] = args
    GossipPushSum.Main.print("Process id:#{inspect(i)} initiated")
    {:ok, args}
  end

  @impl true
  def handle_cast({:gossip, message}, [i, numNodes, count]) do
    GossipPushSum.Main.print("Gossip received for node: #{i}, current count = #{count+1}")
    next_node = GossipPushSum.Registry.get_random(i)

    cond do
      next_node == self() ->
        GossipPushSum.Registry.remove(i)
        {:stop, :normal, [i, numNodes, count+1]}
      (count+1 < @maxGossips) ->
        forward_gossip(i, next_node,message)
        {:noreply, [i, numNodes, count+1]}
      true ->
        forward_gossip(i, next_node,message)
        GossipPushSum.Registry.remove(i)
        {:stop, :normal, [i, numNodes, count+1]}
    end
  end

  @impl true
  def terminate(_reason, [i, _numNodes, _count]) do
    GossipPushSum.Main.print("Limit reached for node: #{i} so shutting down...")
  end

  defp forward_gossip(i, next_node, message) do
    GossipPushSum.Main.print("Gossip forwarding to pid: #{inspect(next_node)} from #{i}")
    GenServer.cast(next_node, {:gossip, message})
  end

end
