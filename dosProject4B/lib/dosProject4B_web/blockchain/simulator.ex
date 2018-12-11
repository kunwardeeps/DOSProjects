defmodule KryptoCoin.Simulator do

  def start(num_nodes) do
    KryptoCoin.Registry.start_link()
    KryptoCoin.ChartMetrics.start_link()
    {_, pid1} = KryptoCoin.Node.start_link(nil)
    initialize_network(num_nodes-1, pid1)
    txn_generator_pid = spawn fn -> create_random_transactions(0) end
    Process.register(txn_generator_pid, :txn_generator)
  end

  def stop() do
    txn_generator_pid = Process.whereis(:txn_generator)
    Process.exit(txn_generator_pid, :kill)
  end

  def initialize_network(n, first_pid) do
    amount_per_node = KryptoCoin.Node.get_first_coinbase_amount() / n+2
    for i <- 0..n, i > 0 do
      {_, pid} = KryptoCoin.Node.start_link(first_pid)
      create_transaction(first_pid, pid, amount_per_node)
    end
  end

  def create_random_transactions(n) do
    IO.inspect(KryptoCoin.ChartMetrics.get_data())
    Process.sleep(1000)
    sender_pid = Enum.random(KryptoCoin.Registry.get_all_values())
    receiver_pid = Enum.random(KryptoCoin.Registry.get_all_values())
    if (sender_pid != receiver_pid) do
      if rem(n,10) == 0 do
        KryptoCoin.Node.mine_block(sender_pid)
      end
      create_random_transaction(sender_pid, receiver_pid)
    end
    create_random_transactions(n+1)
  end

  def create_random_transaction(from_pid, receiver_pid) do
    amount = Enum.random(1..10)/1
    create_transaction(from_pid, receiver_pid, amount)
  end

  def create_transaction(from_pid, receiver_pid, amount) do
    receiver_public_key = KryptoCoin.Node.get_public_key(receiver_pid)
    KryptoCoin.Node.send_funds(from_pid, receiver_public_key, amount)
  end
end
