defmodule DosProject do
  use GenServer
  @moduledoc """
  Documentation for DosProject.
  """

  #Worker (server) methods
  @impl true
  def init(args) do
    #IO.inspect(args)
    {:ok, args}
  end

  @doc """
  Handle async calls
  """
  @impl true
  def handle_cast({:subtask, i, n, k}, state) do
    recurse(i, n, k)
    {:noreply, [state]}
  end

  @doc """
  Outputs first number if sum of squares of given list is a perfect square
  """
  def recurse(i,n,k) do
    if (i <= n) do
      if (getSumOfSquares(i,i+k-1) |> perfectSquare?) do
        IO.puts(i)
      end
      recurse(i+1,n,k)
    end
  end

  @doc """
  Returns sum of a list
  """
  def sum(list) do
    Enum.reduce(list, fn (x,acc) -> x + acc end)
  end

  @doc """
  Returns squared numbers of a list
  """
  def square(list) do
    Enum.map(list, &(&1 * &1))
  end

  @doc """
  Returns sum of squares of a list
  """
  def getSumOfSquares(st, en) do
    Enum.to_list(st..en) |> square() |> sum
  end

  @doc """
  Checks if a number is perfect square
  """
  def perfectSquare?(num) do
    num |> :math.sqrt() |> :erlang.trunc() |> :math.pow(2) == num
  end

  # Supervisor (client) methods

  @doc """
  Use for starting sub tasks for the main problem
  """
  def start(n,k) do
    workunit = getWorkUnit(n)
    numworkers = getNumOfWorkers(n, workunit)
    loop(numworkers, workunit, n, k)
  end

  @doc """
  Start async processes by using Genserver.cast
  """
  def loop(numworkers, workunit, n, k) do
    if numworkers>0 do
      DosProject.loop(numworkers - 1, workunit, n, k)
      i = ((numworkers * workunit) - workunit) + 1
      {:ok, pid} = GenServer.start_link(DosProject, [:subtask], [])
      n1 = if (n - (i - 1)) < workunit, do: n, else: workunit * numworkers
      GenServer.cast(pid, {:subtask, i, n1, k})
    end
  end

  @doc """
  Total number of workers spawned
  """
  def getNumOfWorkers(n,workunit) do
    n/workunit |> Float.ceil |> Kernel.trunc
  end

  @doc """
  Total number of calculations performed by each worker
  """
  def getWorkUnit(n) do
    logn = :math.log(n)/2.303 |> round
    if (logn == 1) do
      n
    else
      :math.pow(10, round(logn/2)) |> trunc
    end
  end
end
