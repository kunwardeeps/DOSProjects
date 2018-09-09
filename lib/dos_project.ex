defmodule DosProject do
  use GenServer
  @moduledoc """
  Documentation for DosProject.
  """

  @impl true
  def init(args) do
    #IO.inspect(args)
    {:ok, args}
  end

  @impl true
  def handle_cast({:subtask, i, n, k}, state) do
    recurse(i, n, k)
    {:noreply, [state]}
  end

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

  def loop(numworkers, workunit, k, n) do
    if numworkers>0 do

      DosProject.loop(numworkers - 1, workunit, k, n)
      i = ((numworkers * workunit) - workunit) + 1
      {:ok, pid} = GenServer.start_link(DosProject, [:subtask], [])
      metric = if (n - (i - 1)) < workunit, do: n, else: workunit * numworkers
      GenServer.cast(pid, {:subtask, i, metric, k})
    end
  end

  @doc """
  Client side.
  Use for starting a new sub task for the problem
  """
  def start(n,k) do

    quantum = round(:math.log(n)/2.303)

    workunit =
      case quantum do
        1 -> :quantum
        _ -> trunc(:math.pow(10, round(quantum/2)))
      end

    numworkers =
      case rem(n, workunit) do
        0 -> div(n, workunit)
        _ -> div(n, workunit) + 1
      end

    loop(numworkers, workunit, k, n)
  end
end
