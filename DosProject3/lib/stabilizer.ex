defmodule Chord.Stabilizer do
  use GenServer

  @impl true
  def init(args) do
    Chord.Main.print("Stabilizer initialized")
    {:ok, args}
  end

  @impl true
  def handle_call({:shutdown}, _from, [pid]) do
    Process.exit(pid, :kill)
    {:reply, :ok, [pid]}
  end

  @impl true
  def handle_cast({:trigger, m}, _state) do
    pid = spawn fn -> loop_stabilize(m) end
    Process.monitor(pid)
    {:noreply, [pid]}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, _pid, reason}, state) do
    Chord.Main.print("Exiting stabilizer reason: #{inspect(reason)}")
    {:stop, :normal, state}
  end

  def loop_stabilize(m) do
    Chord.Main.print("Starting stabilizer...")
    Enum.each(Chord.Registry.get_all(), fn(key) ->
      node = Chord.Registry.get(key)
      if (node != nil) do
        [pid, _node_name, _node_key] = node
        GenServer.call(pid, {:trigger_stabilize, m})
      end
    end)
    Process.sleep(500)
    loop_stabilize(m)
  end
end
