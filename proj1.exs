[n,k] = System.argv
DosProject.start(String.to_integer(n), String.to_integer(k))

defmodule DosProject do
  @moduledoc """
  Documentation for DosProject.
  """

  def start(n,k) do
    recurse(1,n,k)
  end

  def recurse(i,n,k) do
    if (i <= n) do
      if (getSumOfSquares(i,i+k-1) |> perfectSquare?) do
        IO.puts(i)
      else
        recurse(i+1,n,k)
      end
    end
  end

  @doc """
  Hello world.

  ## Examples

      iex> DosProject.hello
      :world

  """

  @doc """
  Utility method for getting sum of a list
  """
  def sum(list) do
    Enum.reduce(list, fn (x,acc) -> x + acc end)
  end

  @doc """
  Utility method for squaring numbers of a list
  """
  def square(list) do
    Enum.map(list, &(&1 * &1))
  end

  def getSumOfSquares(st, en) do
    Enum.to_list(st..en) |> square() |> sum
  end

  def perfectSquare?(num) do
    num |> :math.sqrt() |> :erlang.trunc() |> :math.pow(2) == num
  end

end
