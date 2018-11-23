defmodule KryptoCoin.BlockChain do
  use GenServer

  #Server
  @impl true
  def init(_blockchain) do
    {:ok, []}
  end

  @impl true
  def handle_call({:add_block, block}, _from, blockchain) do
    {_previous_hash, _data, _timestamp, hash} = block
    {:reply, hash, blockchain ++ [block]}
  end

  @impl true
  def handle_call({:get_block_chain}, _from, blockchain) do
    {:reply, blockchain, blockchain}
  end

  def get_block(previous_hash, data) do
    timestamp = :os.system_time(:seconds) |> Integer.to_string()
    str = previous_hash <> data <> timestamp
    hash = KryptoCoin.HashModule.get_hash(str)
    {previous_hash, data, timestamp, hash}
  end

  #API
  def start_link() do
    GenServer.start_link(__MODULE__, [], name: KryptoBlockChain)
  end

  def get_block_chain() do
    GenServer.call(KryptoBlockChain, {:get_block_chain})
  end

  def add_block_chain(previous_hash, data) do
    block = get_block(previous_hash, data)
    GenServer.call(KryptoBlockChain, {:add_block, block})
  end

end
