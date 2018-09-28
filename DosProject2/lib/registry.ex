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
      :error -> {:reply, :error, processes}
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
  def handle_call({:random_value, i}, _from, processes) do
    random_key = Map.keys(processes) |> List.delete(i) |> handle_empty_list(i)
    #IO.puts("i = #{i}, random = #{random_key}")
    {:reply, Map.get(processes, random_key), processes}
  end

  @impl true
  def handle_call({:put, id, pid}, _from, processes) do
    if Map.has_key?(processes, id) do
      {:reply, :already_present, processes}
    else
      {:reply, :ok, Map.put(processes, id, pid)}
    end
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
  def get_random(i) do
    GenServer.call(ProcRegistry, {:random_value, i})
  end

  def remove(key) do
    GenServer.call(ProcRegistry, {:remove, key})
  end

end
