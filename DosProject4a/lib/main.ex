defmodule KryptoCoin.Main do
  @moduledoc """
  Documentation for DosProject4.
  """

  @debug true

  def start() do
    KryptoCoin.Registry.start_link()
    {_, pid1} = KryptoCoin.Node.start_link(nil)
    {_, pid2} = KryptoCoin.Node.start_link(pid1)
    {_, pid3} = KryptoCoin.Node.start_link(pid1)
    {_, pid4} = KryptoCoin.Node.start_link(pid1)

    receiver_public_key = KryptoCoin.Node.get_public_key(pid2)
    KryptoCoin.Node.send_funds(pid1, receiver_public_key, 10.0)
    KryptoCoin.Node.mine_block(pid1)

    {pid1,pid2,pid3,pid3}
  end

  def print(msg) do
    if @debug do
      IO.inspect(msg)
    end
  end
end
