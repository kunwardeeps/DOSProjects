defmodule KryptoCoin.Registry do
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
  def handle_call({:get_all_values}, _from, processes) do
    {:reply, Map.values(processes), processes}
  end

  @impl true
  def handle_call({:put, id, pid}, _from, processes) do
    if Map.has_key?(processes, id) do
      {:reply, :already_present, processes}
    else
      {:reply, :ok, Map.put(processes, id, pid)}
    end
  end


  #API
  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: ProcRegistry)
  end

  def stop_link() do
    GenServer.stop(ProcRegistry)
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

  def get_all_values() do
    GenServer.call(ProcRegistry, {:get_all_values})
  end
end
