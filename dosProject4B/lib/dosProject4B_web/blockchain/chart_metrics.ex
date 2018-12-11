defmodule KryptoCoin.ChartMetrics do
  use GenServer

  """
  1. Transactions successful
  2. Transactions failed
  3. Number of Blocks mined
  4. Total bitcoins in the network
  5. Average balance of users
  """
  #Server
  @impl true
  def init(data) do
    {:ok, [0,0,0,0.0,0.0]}
  end

  @impl true
  def handle_call({:get_data}, _from, data) do
    {:reply, data, data}
  end

  @impl true
  def handle_call({:report_successful_txn}, _from, [txs, txf, blks, totbc, avg]) do
    {:reply, :ok, [txs+1, txf, blks, totbc, avg]}
  end

  @impl true
  def handle_call({:report_failed_txn}, _from, [txs, txf, blks, totbc, avg]) do
    {:reply, :ok, [txs, txf+1, blks, totbc, avg]}
  end

  @impl true
  def handle_call({:report_block, amount}, _from, [txs, txf, blks, totbc, avg]) do
    total_nodes = length(KryptoCoin.Registry.get_all())
    {:reply, :ok, [txs, txf, blks+1, totbc+amount, (totbc+amount)/total_nodes]}
  end

  #API
  def start_link() do
    GenServer.start_link(__MODULE__, [], name: ChartMetrics)
  end

  def report_successful_txn() do
    GenServer.call(ChartMetrics, {:report_successful_txn})
  end

  def report_failed_txn() do
    GenServer.call(ChartMetrics, {:report_failed_txn})
  end

  def report_block(coinbase_amount) do
    GenServer.call(ChartMetrics, {:report_block, coinbase_amount})
  end

  def get_data() do
    GenServer.call(ChartMetrics, {:get_data})
  end
end
