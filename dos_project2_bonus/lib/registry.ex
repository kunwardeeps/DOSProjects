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
  def handle_call({:register_imperfect_line, i, numNodes, pid}, _from, processes) do
    if (Map.has_key?(processes, i)) do
      #correct pid
      [i,0,0,_old_pid,rand] = Map.get(processes, i)
      processes = Map.put(processes, i, [i,0,0,pid,rand])
      {:reply, :updated, processes}
    else
      numList = Enum.to_list(i+2..numNodes) -- Map.keys(processes)
      if (Enum.empty?(numList)) do
        processes = Map.put(processes, i, [i,0,0,pid,i+1])
        processes = Map.put(processes, i+1, [i+1,0,0,pid,i])
        {:reply, :ok, processes}
      else
        rand = Enum.random(numList)
        processes = Map.put(processes, i, [i,0,0,pid,rand])
        processes = Map.put(processes, rand, [rand,0,0,pid,i])
        {:reply, :ok, processes}
      end
    end
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
  def handle_call({:random_imperfect_line, i, numNodes}, _from, processes) do
    value = Map.get(processes, i)
    if (value == nil) do
      {:reply, nil, processes}
    else
      [_,_,_,_,rand] = value
      neighbour_list =
        cond do
          i == 1 ->
            [i+1, rand]
          i == numNodes ->
            [i-1, rand]
          true ->
            [i+1, i-1, rand]
        end
      value2 = Map.get(processes, Enum.random(neighbour_list))
      if (value2 == nil) do
        {:reply, nil, processes}
      else
        [_,_,_,rand_pid,_] = value2
        {:reply, rand_pid, processes}
      end
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
    value = Map.get(processes, current_node)
    [xi,yi,_,_,_i] = value
    neighbour_list = Enum.map(Enum.filter(Map.values(processes), &filterByDistance(xi, yi, &1)), &get_node_id_2d(&1))
    {:reply, neighbour_list -- [current_node], processes}
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

  @impl true
  def handle_call({:toroid_neighbour_list, current_node, numNodes}, _from, processes) do
    [xi,yi,_,_,_i] = Map.get(processes, current_node)

    #IO.inspect GossipPushSum.Registry.get_all()

    IO.inspect xi, label: "xi"
    IO.inspect yi, label: "yi"

    square_root = numNodes |> :math.pow(1/2) |> :math.ceil |> :erlang.trunc

    possible_neighbours =
    cond do
      #first checking for boundary-edge conditions -
      xi == square_root && yi == square_root -> [
        [square_root,0,0],
        [square_root,square_root - 1,0],
        [0,square_root - 1,0],
        [square_root - 1, square_root,0]
      ]
      xi == 1 && yi == 1 -> [
        [xi+1,yi,0],
        [1,square_root,0],
        [xi,yi+1,0],
        [square_root,1,0]
      ]

      xi == 1 && yi == square_root -> [
        [xi+1,yi,0],
        [square_root,yi,0],
        [xi-1,yi,0],
        [1,1,0]
      ]

      xi == square_root && yi == 1 -> [
        [xi-1,yi,0],
        [1,yi,0],
        [square_root,yi+1,0],
        [square_root,square_root,0]
      ]

      #checking for boundary-line conditions -
      xi == square_root -> [
        [square_root,yi-1,0],
        [square_root,yi+1,0],
        [1,yi,0],
        [square_root, yi,0]
      ]

      xi == 1 -> [
        [xi,yi+1,0],
        [xi,yi-1,0],
        [xi+1,yi,0],
        [square_root,yi,0]
      ]

      yi == square_root -> [
        [square_root,yi-1,0],
        [1,yi+1,0],
        [xi,yi+1,0],
        [xi,yi-1,0]
      ]

      yi == 1 -> [
        [xi+1,yi,0],
        [xi-1,yi,0],
        [xi,square_root,0],
        [xi,yi-1,0]
      ]

      #anywhere else on the grid
      xi != 1 && xi != square_root -> [
        [xi+1,yi,0],
        [xi-1,yi,0],
        [xi,yi+1,0],
        [xi,yi-1,0]
      ]

    end

    IO.inspect possible_neighbours, label: "possible_neighbours"
    neighbour_list = Enum.map(possible_neighbours, &get_node_id_toroid_from_coordinates(&1, numNodes))
    IO.inspect neighbour_list, label: "neighbour_list ->"
    {:reply, neighbour_list, processes}

  end

  def get_node_id_2d(node) do
    [_,_,_,_,i] = node
    i
  end

  def get_num_list(i, numNodes) do
    numList =
      cond do
        (i == 1) ->
          Enum.to_list(3..numNodes)
        (i == numNodes) ->
          Enum.to_list(1..numNodes-2)
        true ->
          Enum.to_list(1..i-2) ++ Enum.to_list(i+2..numNodes)
      end
    numList
  end

  def get_node_id_toroid_from_coordinates([x,y,z], numNodes) do
    square_root = get_square_root_ceiling(numNodes)
    (square_root * (x-1) + y + z*0)
  end

  def register_process_toroid(i, numNodes, pid) do
    #to determine x & y co-ordinates -
    square_root = numNodes |> :math.pow(1/2) |> :math.ceil |> :erlang.trunc

    y = i/square_root |> :math.ceil |> :erlang.trunc
    rem_x = rem(i, square_root)

    x = if (rem_x==0) do
          square_root
        else
          rem_x
        end

    IO.inspect x, label: "x"
    IO.inspect y, label: "y"
    GossipPushSum.Registry.put(i, [x, y, 0, pid, i])
  end

  def filterByDistance(xi, yi, node) do
    [x,y,_,_,_] = node
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

  def get_square_root_ceiling(n) do
    n |> :math.pow(1/2) |> :math.ceil |> :erlang.trunc
  end

  def get_toroid_neighbour_list(current_node, numNodes) do
    GenServer.call(ProcRegistry, {:toroid_neighbour_list, current_node, numNodes})
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

  def get_node_distance(x1, y1, x2, y2) do
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
    GenServer.call(ProcRegistry, {:random_value_line, current_node, numNodes})
  end

  def get_random_imperfect_line(current_node, numNodes) do
    GenServer.call(ProcRegistry, {:random_imperfect_line, current_node, numNodes})
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
      "imperfect_line" -> get_random_imperfect_line(current_node, numNodes)
      "toroid" -> Enum.random(neighbour_list) |> GossipPushSum.Registry.get() |> handle_nil()
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
      "full_network" -> put(i, [i,0,0,pid,i])
      "line" -> put(i, [i,0,0,pid,i])
      "random_2d" -> register_random_2d(i, numNodes, pid)
      "3d" -> register_process_3d(i, numNodes, pid)
      "imperfect_line" -> register_imperfect_line(i, numNodes, pid)
      "toroid" -> register_process_toroid(i, numNodes, pid)
      _ -> IO.puts("Error: Invalid topology!")
    end
  end

  def register_random_2d(i, numNodes, pid) do
    sqrt = get_square_root_ceiling(numNodes)
    put(i, [:rand.uniform(sqrt)/(numNodes), :rand.uniform(sqrt)/(numNodes), 0, pid, i])
  end

  def register_imperfect_line(i, numNodes, pid) do
    GenServer.call(ProcRegistry, {:register_imperfect_line, i, numNodes, pid})
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
      "toroid" -> get_toroid_neighbour_list(current_node, numNodes)
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
