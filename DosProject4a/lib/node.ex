defmodule KryptoCoin.Node do
  use GenServer

  @init_amount 100.0

  @impl true
  def init(existing_node_pid) do
    transaction_pool = %{}
    if (existing_node_pid == nil) do
      wallet = KryptoCoin.Wallet.generate(@init_amount)
      coinbase = KryptoCoin.Transaction.generate_coinbase(@init_amount, wallet.public_key, wallet.private_key)
      blockchain = [KryptoCoin.Block.initialize(coinbase)]
      KryptoCoin.Registry.put(wallet.public_key, self())
      {:ok, [blockchain, wallet, transaction_pool]}
    else
      wallet = KryptoCoin.Wallet.generate(0.0)
      blockchain = get_block_chain(existing_node_pid)
      KryptoCoin.Registry.put(wallet.public_key, self())
      {:ok, [blockchain, wallet, transaction_pool]}
    end
  end

  @impl true
  def handle_call({:update_utxo, amount, new_amount}, _from, state) do
    [blockchain, wallet, transaction_pool] = state
    wallet = KryptoCoin.Wallet.update_utxos(wallet, amount, new_amount)
    {:reply, :ok, [blockchain, wallet, transaction_pool]}
  end

  @impl true
  def handle_call({:add_utxo, amount}, _from, state) do
    [blockchain, wallet, transaction_pool] = state
    wallet = KryptoCoin.Wallet.add_utxo(wallet, amount)
    {:reply, :ok, [blockchain, wallet, transaction_pool]}
  end

  @impl true
  def handle_call({:delete_utxo, amount}, _from, state) do
    [blockchain, wallet, transaction_pool] = state
    wallet = KryptoCoin.Wallet.remove_utxo(wallet, amount)
    {:reply, :ok, [blockchain, wallet, transaction_pool]}
  end

  @impl true
  def handle_call({:get_balance}, _from, state) do
    [blockchain, wallet, transaction_pool] = state
    {:reply, KryptoCoin.Wallet.get_balance(wallet), [blockchain, wallet, transaction_pool]}
  end

  @impl true
  def handle_call({:send_funds, receiver_public_key, amount}, _from, state) do
    [blockchain, wallet, transaction_pool] = state
    receiver_pid = KryptoCoin.Registry.get(receiver_public_key)
    if amount > get_balance(receiver_pid) do
      {:reply, :insufficient_funds, [blockchain, wallet, transaction_pool]}
    else
      transaction = KryptoCoin.Transaction.generate_transaction(amount, wallet, receiver_public_key)
      txn_outputs = transaction.outputs
      receiver_pid = KryptoCoin.Registry.get(receiver_public_key)
      KryptoCoin.Node.add_utxo(receiver_pid, amount)
      transaction_pool = Map.put(transaction_pool, transaction.id, transaction)
      if (Enum.count(txn_outputs) == 2) do
        wallet = KryptoCoin.Wallet.update_utxos(wallet, transaction.inputs, Enum.at(txn_outputs,1).amount)
        {:reply, transaction, [blockchain, wallet, transaction_pool]}
      else
        {:reply, transaction, [blockchain, wallet, transaction_pool]}
      end
    end
  end

  @impl true
  def handle_call({:broadcast_block}, _from, state) do

  end

  @impl true
  def handle_call({:get_block_chain}, _from, [blockchain, wallet, transaction_pool]) do
    {:reply, blockchain, [blockchain, wallet, transaction_pool]}
  end

  #API
  def start_link(params) do
    GenServer.start_link(__MODULE__, params)
  end

  def update_utxo(pid, amount, new_amount) do
    GenServer.call(pid, {:update_utxo, amount, new_amount})
  end

  def add_utxo(pid, amount) do
    GenServer.call(pid, {:add_utxo, amount})
  end

  def delete_utxo(pid, amount) do
    GenServer.call(pid, {:delete_utxo, amount})
  end

  def send_funds(pid, receiver_public_key, amount) do
    GenServer.call(pid, {:send_funds, receiver_public_key, amount})
  end

  def get_balance(pid) do
    GenServer.call(pid, {:get_balance})
  end

  def broadcast_block(block, self_public_key) do
    list_of_nodes = KryptoCoin.Registry.get_all_values() -- [self()]
    for node <- list_of_nodes do
      GenServer.call(node, {:broadcast_block, block})
    end
  end

  def get_block_chain(pid) do
    GenServer.call(pid, {:get_block_chain})
  end

end
