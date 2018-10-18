defmodule Chord.Main do
  @moduledoc """
  Documentation for DosProject3.
  """
  @debug true

  def start(num_nodes, num_requests, failure_nodes \\ 0) do
    print("Hello World #{inspect(failure_nodes)}")
  end

  def print(msg) do
    if @debug do
      IO.inspect(msg)
    end
  end
end
