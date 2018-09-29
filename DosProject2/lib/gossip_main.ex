defmodule GossipMain do
  use GenServer

  @impl true
  def init([numNodes, exit_count, main_pid, topology]) do
    init_nodes(numNodes, 1, topology)
    {:ok, [numNodes, exit_count, main_pid, topology]}
  end

  @impl true
  def handle_call(_request, _from, [numNodes, exit_count, main_pid, topology]) do
    start(numNodes)
    {:reply, [], [numNodes, exit_count, main_pid, topology]}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, [numNodes, exit_count, main_pid, topology]) do
    if (exit_count+1 < numNodes) do
      GossipPushSum.Main.print "Process #{inspect(pid)} down, exit count: #{exit_count+1}!"
      {:noreply, [numNodes, exit_count+1, main_pid, topology]}
    else
      GossipPushSum.Main.print("exit count: #{exit_count+1}, so converging...")
      send(main_pid, {:converge, "Converged!"})
      {:noreply, [numNodes, exit_count+1, main_pid, topology]}
    end
  end

  def start(numNodes) do
    first_node = GossipPushSum.Registry.get(:rand.uniform(numNodes))
    GossipPushSum.Main.print("Gossip starting from #{inspect(first_node)}")
    GenServer.cast(first_node, {:gossip, "Java sucks"})
  end

  def init_nodes(numNodes, i, topology) do
    if (i <= numNodes) do
      {:ok, pid} = GenServer.start_link(Gossip.Node, [i, numNodes, 0, topology, self()])

      IO.puts(topology)

      register_process(i, topology, numNodes, pid)

      Process.monitor(pid)
      init_nodes(numNodes, i+1, topology)
    end
  end

  def register_process(i, topology, numNodes, pid) do
    case topology do
      "full_network" -> GossipPushSum.Registry.put(i, [i,0,0,pid])
      "line" -> GossipPushSum.Registry.put(i, [i,0,0,pid])
      #"imperfect_line" -> register_process_imperfect_line
      "random_2d" -> GossipPushSum.Registry.put(i, [:rand.uniform(numNodes)/numNodes, :rand.uniform(numNodes)/numNodes, 0, pid])
      #"3d" -> assign3d_grid(i, numNodes)

      register_process_3d(i, numNodes)
    end


    GossipPushSum.Registry.put(i, pid)
  end

  def register_process_3d(i, numNodes) do

    cube_root = numNodes |> :math.pow(1/3) |> :math.ceil |> :erlang.trunc
    cube_root_sq = cube_root |> :math.pow(2) |> :erlang.trunc
    z = i/cube_root_sq |> :math.ceil|> :erlang.trunc
    rem_z = i |> rem(cube_root_sq)
    if (rem_z == 0) do
      [cube_root, cube_root, z]
    else
      y = rem_z / cube_root |> :math.ceil |> :erlang.trunc
      rem_y = rem_z |> rem(cube_root)
      if rem_y == 0 do
        [cube_root, y, z]
      else
        x = rem_y
        [x, y, z]
      end
    end

  end

end
