defmodule KryptoCoin.Node do
  use GenServer

  @impl true
  def init([init_amount]) do
    wallet = KryptoCoin.Wallet.generate(init_amount)
    coinbase = KryptoCoin.Transaction.generate_coinbase(init_amount, wallet.public_key, wallet.private_key)
    blockchain = []
    transaction_pool = %{coinbase.id => coinbase}
    KryptoCoin.Registry.put(wallet.public_key, self())
    {:ok, [blockchain, wallet, transaction_pool]}
  end

  @impl true
  def handle_call({:update_utxo, amount, new_amount}, _from, state) do
    [blockchain, wallet, transaction_pool] = state
    wallet = KryptoCoin.Wallet.update_utxo(wallet, amount, new_amount)
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
end
