defmodule PushSum.Node do
  use GenServer, restart: :transient

  @impl true
  def init(args) do
    [_numNodes, i, _s, _w, _warning_count] = args
    GossipPushSum.Main.print("Process id:#{inspect(i)} initiated")
    {:ok, args}
  end

  # @impl true
  # def handle_cast({:first_message, s, w}, [numNodes, i, s, w, warning_count]) do
  #   GossipPushSum.Main.print("Message received for node: #{i}, state = #{inspect([numNodes, i, s, w, warning_count])}")
  #   next_node = GossipPushSum.Registry.get_random(i)
  #   forward_message(i, next_node, s/2, w/2)
  #   {:noreply, [numNodes, i, s/2, w/2, warning_count]}
  # end

  @impl true
  def handle_cast({:message, s1, w1}, [numNodes, i, s, w, warning_count]) do
    GossipPushSum.Main.print("Message #{inspect{:message, s1, w1}} received for node: #{i}, state = #{inspect([numNodes, i, s, w, warning_count])}")
    next_node = GossipPushSum.Registry.get_random(i)
    new_s = (s1 + s)/2
    new_w = (w1 + w)/2
    new_warning_count = get_warning_count(s/w, new_s/new_w, warning_count)
    new_state = [numNodes, i, new_s, new_w, new_warning_count]
    #GossipPushSum.Main.print("For node: #{i}, state = #{inspect(new_state)}")
    cond do
      #Last node case
      next_node == self() ->
        GossipPushSum.Registry.remove(i)
        {:stop, :normal, new_state}
      #Case if forward can be done
      (new_warning_count < 3) ->
        forward_message(i, next_node, new_s, new_w)
        {:noreply, new_state}
      #Case when limit is reached
      true ->
        forward_message(i, next_node, new_s, new_w)
        GossipPushSum.Registry.remove(i)
        {:stop, :normal, new_state}
    end
  end

  def get_warning_count(r1, r2, warning_count) do
    if (abs(r1-r2) < 1.0e-10) do
      warning_count + 1
    else
      warning_count
    end
  end

  @impl true
  def terminate(_reason, [_numNodes, i, _s, _w, _warning_count]) do
    GossipPushSum.Main.print("Limit reached for node: #{i} so shutting down...")
  end

  defp forward_message(i, next_node, new_s, new_w) do
    GossipPushSum.Main.print("Message forwarding to pid: #{inspect(next_node)} from #{i}")
    GenServer.cast(next_node, {:message, new_s, new_w})
  end

end
