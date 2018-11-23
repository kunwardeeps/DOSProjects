defmodule KryptoCoin.Main do
  @moduledoc """
  Documentation for DosProject4.
  """

  @debug true

  def start() do
    KryptoCoin.Registry.start_link()
    {_, pid1} = KryptoCoin.Node.start_link([100.0])
    {_, pid2} = KryptoCoin.Node.start_link([100.0])
    public_keys = KryptoCoin.Registry.get_all()
    KryptoCoin.Node.send_funds(pid1, Enum.at(public_keys, 1), 60.0)
    print(KryptoCoin.Node.get_balance(pid1))
    print(KryptoCoin.Node.get_balance(pid2))
  end

  def print(msg) do
    if @debug do
      IO.inspect(msg)
    end
  end
end
