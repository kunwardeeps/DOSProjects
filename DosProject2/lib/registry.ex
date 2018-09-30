defmodule GossipPushSum.Registry do
  use GenServer

  #Server
  @impl true
  def init(processes) do
    {:ok, processes}
  end

  @impl true
  def handle_call({:get, id}, _from, processes) do
    case Map.fetch(processes, id) do
      {:ok, value} -> {:reply, value, processes}
      :error -> {:reply, nil, processes}
    end
  end

  @impl true
  def handle_call({:remove, id}, _from, processes) do
    {:reply, :ok, Map.delete(processes, id)}
  end

  @impl true
  def handle_call({:get_all}, _from, processes) do
    {:reply, Map.keys(processes), processes}
  end

  @impl true
  def handle_call({:random_value_full, i}, _from, processes) do
    random_key = Map.keys(processes) |> List.delete(i) |> handle_empty_list(i)
    [_,_,_,pid,_] = Map.get(processes, random_key)
    #IO.puts("i = #{i}, random = #{random_key}")
    {:reply, pid, processes}
  end

  @impl true
  def handle_call({:get_neighbour_list, i}, _from, processes) do
    random_key = Map.keys(processes) |> List.delete(i) |> handle_empty_list(i)
    #IO.puts("i = #{i}, random = #{random_key}")
    {:reply, Map.get(processes, random_key), processes}
  end

  @impl true
  def handle_call({:random_value_line, i, numNodes}, _from, processes) do
    value =
      cond do
        i == 1 ->
          Map.get(processes, i+1)
        i == numNodes ->
          Map.get(processes, i-1)
        true ->
          Map.get(processes, i+Enum.random([-1,1]))

      end

    if (value == nil) do
      {:reply, nil, processes}
    else
      [_,_,_,pid,_] = value
      {:reply, pid, processes}
    end

  end

  @impl true
  def handle_call({:put, id, pid}, _from, processes) do
    if Map.has_key?(processes, id) do
      {:reply, :already_present, processes}
    else
      {:reply, :ok, Map.put(processes, id, pid)}
    end
  end

  @impl true
  def handle_call({:random_2d_neighbour_list, current_node}, _from, processes) do
    [xi,yi,_,_,_i] = Map.get(processes, current_node)
    neighbour_list = Enum.filter(Map.values(processes), &filterByDistance(xi, yi, &1))
    {:reply, neighbour_list, processes}
  end

  @impl true
  def handle_call({:three_d_neighbour_list, current_node, numNodes}, _from, processes) do
    [xi,yi,zi,_,_i] = Map.get(processes, current_node)
    possible_neighbours = [
      [xi+1,yi,zi],
      [xi-1,yi,zi],
      [xi,yi+1,zi],
      [xi,yi-1,zi],
      [xi,yi,zi+1],
      [xi,yi,zi-1]
    ]
    neighbour_list = Enum.map(Enum.filter(possible_neighbours, &is_valid_3d_node(&1, numNodes)), &get_node_id_from_coordinates(&1, numNodes))

    {:reply, neighbour_list, processes}
  end

  def filterByDistance(xi, yi, node) do
    [x,y,_,_] = node
    get_node_distance(x,y,xi,yi) < 0.1
  end

  def is_valid_3d_node([x,y,z], numNodes) do
    cube_root = get_cube_root_ceiling(numNodes)
    node_id = get_node_id_from_coordinates([x,y,z], numNodes)
    (x > 0 && x <= cube_root) &&
    (y > 0 && y <= cube_root) &&
    (z > 0 && z <= cube_root) &&
    node_id > 0 && node_id <= numNodes
  end

  def get_node_pid_from_coordinates([x,y,z], numNodes, processes) do
    [_,_,_,pid,_i] = Map.get(processes, get_node_id_from_coordinates([x,y,z], numNodes))
    pid
  end

  def get_node_id_from_coordinates([x,y,z], numNodes) do
    cube_root = get_cube_root_ceiling(numNodes)
    cube_root_sq = get_int_square(cube_root)
    (cube_root_sq * (z-1) + cube_root * (y-1) + x)
  end

  def get_node_distance(x1, x2, y1, y2) do
    :math.sqrt(:math.pow(x1 - x2, 2) + :math.pow(y1 - y2, 2))
  end

  def handle_empty_list(list, i) do
    if Enum.empty?(list) do
      i
    else
      Enum.random(list)
    end

  end

  #API
  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: ProcRegistry)
  end

  def put(key, value) do
    GenServer.call(ProcRegistry, {:put, key, value})
  end

  def get(key) do
    GenServer.call(ProcRegistry, {:get, key})
  end

  def get_all() do
    GenServer.call(ProcRegistry, {:get_all})
  end

  #Excludes ith key
  def get_random_full_network(i) do
    GenServer.call(ProcRegistry, {:random_value_full, i})
  end

  def remove(key) do
    GenServer.call(ProcRegistry, {:remove, key})
  end

  def get_random_line(current_node, numNodes) do
    pid = GenServer.call(ProcRegistry, {:random_value_line, current_node, numNodes})
    if (pid == nil) do
      get_random_line(current_node, numNodes)
    else
      pid
    end
  end

  def get_random_2d(current_node, numNodes) do
    GenServer.call(ProcRegistry, {:random_value_2d, current_node, numNodes})
  end

  def get_next_node(current_node, topology, numNodes, neighbour_list) do
    case topology do
      "full_network" -> get_random_full_network(current_node)
      "line" -> get_random_line(current_node, numNodes)
      "random_2d" ->
        if (Enum.empty?(neighbour_list)) do
          nil
        else
          Enum.random(neighbour_list) |> GossipPushSum.Registry.get() |> handle_nil()
        end

      "3d" ->
        if (Enum.empty?(neighbour_list)) do
          nil
        else
          Enum.random(neighbour_list) |> GossipPushSum.Registry.get() |> handle_nil()
        end
      # "imperfect_line" -> get_random_imperfect_line(current_node)
      # "toroid" -> get_random_toroid(current_node)
      _ -> IO.puts("Error: Invalid topology!")
    end
  end

  def handle_nil(node) do
    if (node == nil)do
      nil
    else
      [_,_,_,pid,_] = node
      pid
    end
  end

  def register_process(i, topology, numNodes, pid) do
    case topology do
      "full_network" -> GossipPushSum.Registry.put(i, [i,0,0,pid,i])
      "line" -> GossipPushSum.Registry.put(i, [i,0,0,pid,i])
      "random_2d" -> GossipPushSum.Registry.put(i, [:rand.uniform(numNodes)/numNodes, :rand.uniform(numNodes)/numNodes, 0, pid, i])
      "3d" -> GossipPushSum.Registry.register_process_3d(i, numNodes, pid)
      #"imperfect_line" -> register_process_imperfect_line
      #"toroid" -> register_process_toroid
    end
  end

  def register_process_3d(i, numNodes, pid) do

    cube_root = get_cube_root_ceiling(numNodes)
    cube_root_sq = get_int_square(cube_root)
    z = i/cube_root_sq |> :math.ceil|> :erlang.trunc
    rem_z = i |> rem(cube_root_sq)
    if (rem_z == 0) do
      GossipPushSum.Registry.put(i, [cube_root, cube_root, z, pid, i])
    else
      y = rem_z / cube_root |> :math.ceil |> :erlang.trunc
      rem_y = rem_z |> rem(cube_root)
      if rem_y == 0 do
        GossipPushSum.Registry.put(i, [cube_root, y, z, pid, i])
      else
        x = rem_y
        GossipPushSum.Registry.put(i, [x, y, z, pid, i])
      end
    end

  end

  def get_int_square(n) do
    n |> :math.pow(2) |> :erlang.trunc
  end

  def get_cube_root_ceiling(n) do
    n |> :math.pow(1/3) |> :math.ceil |> :erlang.trunc
  end

  def get_neighbour_list(current_node, topology, numNodes) do
    case topology do
      "random_2d" -> get_random_2d_neighbour_list(current_node)
      "3d" -> get_3d_neighbour_list(current_node, numNodes)
      _ -> []
    end
  end

  def get_random_2d_neighbour_list(current_node) do
    GenServer.call(ProcRegistry, {:random_2d_neighbour_list, current_node})
  end

  def get_3d_neighbour_list(current_node, numNodes) do
    GenServer.call(ProcRegistry, {:three_d_neighbour_list, current_node, numNodes})
  end

end
