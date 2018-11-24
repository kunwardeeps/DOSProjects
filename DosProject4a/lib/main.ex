defmodule KryptoCoin.Main do
  @moduledoc """
  Documentation for DosProject4.
  """

  @debug true

  def start() do
    KryptoCoin.Registry.start_link()
    {_, pid1} = KryptoCoin.Node.start_link(nil)
    {_, pid2} = KryptoCoin.Node.start_link(pid1)
    {pid1,pid2}
  end

  def print(msg) do
    if @debug do
      IO.inspect(msg)
    end
  end
end
