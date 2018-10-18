defmodule Chord.Registry do
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
  def handle_call({:successor, key}, _from, processes) do
    keys = Map.keys(processes) |> Enum.sort()
    keys_with_idx = keys |> Enum.with_index

    if !Map.has_key?(processes, key) do
      {:reply, nil, processes}
    else
      case get_successor_loop(processes, keys_with_idx, key, keys) do
        {:ok, value} -> {:reply, value, processes}
        :error -> {:reply, nil, processes}
      end
    end
  end

  @impl true
  def handle_call({:predecessor, key}, _from, processes) do
    keys = Map.keys(processes) |> Enum.sort()
    keys_with_idx = keys |> Enum.with_index

    if !Map.has_key?(processes, key) do
      {:reply, nil, processes}
    else
      case get_predecessor_loop(processes, keys_with_idx, key, keys) do
        {:ok, value} -> {:reply, value, processes}
        :error -> {:reply, nil, processes}
      end
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
  def handle_call({:put, id, pid}, _from, processes) do
    if Map.has_key?(processes, id) do
      {:reply, :already_present, processes}
    else
      {:reply, :ok, Map.put(processes, id, pid)}
    end
  end

  def get_successor_loop(processes, [head|tail], key, keys) do
    {item, idx} = head
    cond do
      item == key ->
        if Enum.empty?(tail) do
          Map.fetch(processes, Enum.at(keys,0))
        else
          Map.fetch(processes, Enum.at(keys,idx+1))
        end
      true ->
        get_successor_loop(processes, tail, key, keys)
    end
  end

  def get_predecessor_loop(processes, [head|tail], key, keys) do
    {item, idx} = head
    cond do
      item == key ->
        if idx == 0 do
          Map.fetch(processes, Enum.at(keys,length(keys)-1))
        else
          Map.fetch(processes, Enum.at(keys,idx-1))
        end
      true ->
        get_predecessor_loop(processes, tail, key, keys)
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

  def remove(key) do
    GenServer.call(ProcRegistry, {:remove, key})
  end

  def get_successor(key) do
    GenServer.call(ProcRegistry, {:successor, key})
  end

  def get_predecessor(key) do
    GenServer.call(ProcRegistry, {:predecessor, key})
  end

end
