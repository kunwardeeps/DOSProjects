defmodule KryptoCoin.Node do
  use GenServer

  @coinbase_amount 100.0

  @impl true
  def init(existing_node_pid) do
    transaction_pool = %{}
    wallet = KryptoCoin.Wallet.generate()

    if (existing_node_pid == nil) do
      coinbase = KryptoCoin.Transaction.generate_coinbase(@coinbase_amount, wallet.public_key, wallet.private_key)
      utxos = %{Enum.at(coinbase.outputs,0).txoid => Enum.at(coinbase.outputs,0)}
      blockchain = [KryptoCoin.Block.initialize(coinbase)]
      KryptoCoin.Registry.put(wallet.public_key, self())
      {:ok, [blockchain, wallet, transaction_pool, utxos]}
    else
      utxos = get_utxos(existing_node_pid)
      blockchain = get_block_chain(existing_node_pid)
      KryptoCoin.Registry.put(wallet.public_key, self())
      {:ok, [blockchain, wallet, transaction_pool, utxos]}
    end
  end

  @impl true
  def handle_call({:send_funds, receiver_public_key, amount}, _from, state) do
    [blockchain, wallet, transaction_pool, utxos] = state
    balance = KryptoCoin.Wallet.get_balance(utxos, wallet.public_key)

    KryptoCoin.Main.print("Trying to send #{amount}, balance = #{balance}, utxos = #{inspect(utxos)}")

    if amount > balance do
      KryptoCoin.Main.print("Insufficient funds")
      {:reply, :insufficient_funds, [blockchain, wallet, transaction_pool, utxos]}
    else
      transaction = KryptoCoin.Transaction.generate_transaction(amount, wallet, receiver_public_key, utxos)
      transaction_pool = Map.put(transaction_pool, transaction.id, transaction)

      status = broadcast_transaction(transaction)

      if (status == :ok) do
        utxos = update_utxos(transaction, utxos)
        {:reply, transaction, [blockchain, wallet, transaction_pool, utxos]}
      else
        {:reply, status, [blockchain, wallet, transaction_pool, utxos]}
      end
    end
  end

  @impl true
  def handle_call({:receive_transaction, transaction}, _from, [blockchain, wallet, transaction_pool, utxos]) do
    result = KryptoCoin.Transaction.validate(transaction, utxos)
    KryptoCoin.Main.print("Transaction received, result = #{result}")
    if (result == :ok) do
      utxos = update_utxos(transaction, utxos)
      transaction_pool = Map.put(transaction_pool, transaction.id, transaction)
      {:reply, result, [blockchain, wallet, transaction_pool, utxos]}
    else
      {:reply, result, [blockchain, wallet, transaction_pool, utxos]}
    end
  end

  @impl true
  def handle_call({:receive_block, block}, _from, [blockchain, wallet, transaction_pool, utxos]) do
    result = KryptoCoin.Block.validate(block, blockchain ++ [block])
    KryptoCoin.Main.print("Block received, result = #{result}")
    if (result == :ok) do
      transaction_pool = Map.drop(transaction_pool, Enum.map(block.transactions, fn(txn) -> txn.id end))
      coinbase = KryptoCoin.Block.get_coinbase(block)
      utxos = Map.put(utxos, Enum.at(coinbase.outputs,0).txoid, Enum.at(coinbase.outputs,0))
      {:reply, result, [blockchain ++ [block], wallet, transaction_pool, utxos]}
    else
      {:reply, result, [blockchain, wallet, transaction_pool, utxos]}
    end
  end

  @impl true
  def handle_call({:get_block_chain}, _from, [blockchain, wallet, transaction_pool, utxos]) do
    {:reply, blockchain, [blockchain, wallet, transaction_pool, utxos]}
  end

  @impl true
  def handle_call({:get_utxos}, _from, [blockchain, wallet, transaction_pool, utxos]) do
    {:reply, utxos, [blockchain, wallet, transaction_pool, utxos]}
  end

  @impl true
  def handle_call({:get_public_key}, _from, [blockchain, wallet, transaction_pool, utxos]) do
    {:reply, wallet.public_key, [blockchain, wallet, transaction_pool, utxos]}
  end

  @impl true
  def handle_call({:get_balance}, _from, [blockchain, wallet, transaction_pool, utxos]) do
    {:reply, KryptoCoin.Wallet.get_balance(utxos, wallet.public_key), [blockchain, wallet, transaction_pool, utxos]}
  end

  @impl true
  def handle_call({:get_transaction_pool}, _from, [blockchain, wallet, transaction_pool, utxos]) do
    {:reply, transaction_pool, [blockchain, wallet, transaction_pool, utxos]}
  end

  @impl true
  def handle_call({:mine_block}, _from, [blockchain, wallet, transaction_pool, utxos]) do
    if (Enum.count(transaction_pool) == 0) do
      KryptoCoin.Main.print("No transactions to mine in the pool!")
      {:reply, :no_transactions, [blockchain, wallet, transaction_pool, utxos]}
    else
      coinbase = KryptoCoin.Transaction.generate_coinbase(@coinbase_amount, wallet.public_key, wallet.private_key)
      block = KryptoCoin.Block.generate_block(Map.values(transaction_pool) ++ [coinbase], List.last(blockchain))
      result = broadcast_block(block)
      if result == :ok do
        transaction_pool = Map.drop(transaction_pool, Enum.map(block.transactions, fn(txn) -> txn.id end))
        utxos = Map.put(utxos, Enum.at(coinbase.outputs,0).txoid, Enum.at(coinbase.outputs,0))
        {:reply, block, [blockchain ++ [block], wallet, transaction_pool, utxos]}
      else
        {:reply, block, [blockchain, wallet, transaction_pool, utxos]}
      end
    end
  end

  #API
  def start_link(params) do
    GenServer.start_link(__MODULE__, params)
  end

  def send_funds(sender_pid, receiver_public_key, amount) do
    GenServer.call(sender_pid, {:send_funds, receiver_public_key, amount})
  end

  def get_public_key(pid) do
    GenServer.call(pid, {:get_public_key})
  end

  def broadcast_block(block) do
    nodes = KryptoCoin.Registry.get_all_values() -- [self()]
    count = Enum.count(nodes, &(GenServer.call(&1, {:receive_block, block}) == :ok))
    #Consensus logic
    approval = count/Enum.count(nodes)
    if (approval >= 0.51) do
      KryptoCoin.Main.print("Block validated by #{inspect(approval * 100)}% peers!")
      :ok
    else
      KryptoCoin.Main.print("Block failed to meet consensus by #{inspect(approval * 100)}% peers!")
      :block_disapproved
    end
  end

  def broadcast_transaction(transaction) do
    nodes = KryptoCoin.Registry.get_all_values() -- [self()]
    count = Enum.count(nodes, &(GenServer.call(&1, {:receive_transaction, transaction}) == :ok))
    #Consensus logic
    approval = count/Enum.count(nodes)
    if (approval >= 0.51) do
      KryptoCoin.Main.print("Transaction validated by #{inspect(approval * 100)}% peers!")
      :ok
    else
      KryptoCoin.Main.print("Transaction failed to meet consensus by #{inspect(approval * 100)}% peers!")
      :transaction_failed
    end
  end

  def get_block_chain(pid) do
    GenServer.call(pid, {:get_block_chain})
  end

  def get_utxos(pid) do
    GenServer.call(pid, {:get_utxos})
  end

  def update_utxos(transaction, utxos) do
    utxos = Map.drop(utxos, Enum.map(transaction.inputs, fn(tx_input) -> tx_input.txoid end))
    if (Enum.count(transaction.outputs) == 2) do
      [txop1, txop2] = transaction.outputs
      utxos = Map.put(utxos, txop1.txoid, txop1)
      Map.put(utxos, txop2.txoid, txop2)

    else
      #Case when amount is equal to balance
      [txop1] = transaction.outputs
      Map.put(utxos, txop1.txoid, txop1)
    end
  end

  def mine_block(pid) do
    GenServer.call(pid, {:mine_block})
  end

  def get_coinbase_amount() do
    @coinbase_amount
  end

  def get_balance(pid) do
    GenServer.call(pid, {:get_balance})
  end

  def get_transaction_pool(pid) do
    GenServer.call(pid, {:get_transaction_pool})
  end

end
