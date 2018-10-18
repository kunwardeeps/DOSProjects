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
    keys = Map.keys(processes) |> Enum.sort() |> Enum.with_index

    result = {:reply, nil, processes}
    for {item, idx} <- keys do
      if (item == key) do
        if (idx == length(keys) - 1) do
          {next_item, _} = Enum.at(keys,0)
          case Map.fetch(processes, next_item) do
            {:ok, value} -> result = {:reply, value, processes}
            :error -> result = {:reply, nil, processes}
          end
        else
          {next_item, _} = Enum.at(keys,idx+1)
          IO.puts("hello")
          case Map.fetch(processes, next_item) do
            {:ok, value} -> result = {:reply, value, processes}
            :error -> result = {:reply, nil, processes}
          end
        end
      end
    end
    result
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
