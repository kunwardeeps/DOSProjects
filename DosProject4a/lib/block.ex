defmodule KryptoCoin.Block do
  @difficulty 2
  defstruct index: nil,
            hash: nil,
            previous_hash: nil,
            nonce: 0,
            timestamp: nil,
            transactions: []

  def get_difficulty() do
    @difficulty
  end

  def initialize(coinbase_txn) do
    timestamp = :os.system_time(:seconds)
    index = 0
    prev_hash = "0"
    {nonce, hash} = calculate_hash(index, prev_hash, 0, timestamp, [coinbase_txn])
    %KryptoCoin.Block{
      index: 0,
      nonce: nonce,
      timestamp: timestamp,
      hash: hash,
      previous_hash: prev_hash,
      transactions: [coinbase_txn]
    }
  end

  def generate_block(transactions, last_block) do
    timestamp = :os.system_time(:seconds)
    index = last_block.index + 1
    prev_hash = last_block.hash
    {nonce, hash} = calculate_hash(index, prev_hash, 0, timestamp, transactions)
    %KryptoCoin.Block{
      index: index,
      nonce: nonce,
      timestamp: timestamp,
      hash: hash,
      previous_hash: prev_hash,
      transactions: transactions
    }
  end

  def get_coinbase(block) do
    Enum.find(block.transactions, fn(transaction) -> transaction.type == "coinbase" end)
  end

  def validate(block, blockchain) do
    hash = get_hash(block)
    coinbase = get_coinbase(block)
    first_block = Enum.at(blockchain, 0)
    cond do
      hash != block.hash ->
        :invalid_hash
      String.duplicate("0",@difficulty) != String.slice(block.hash,0,@difficulty) ->
        :invalid_nonce
      coinbase == nil ->
        :coinbase_not_found
      coinbase.amount > KryptoCoin.Node.get_coinbase_amount() ->
        :invalid_coinbase_amount
      !validate_blockchain(blockchain, 1, first_block) ->
        :invalid_blockchain
      true ->
        :ok
    end
  end

  def validate_blockchain(blockchain, index, prev_block) do
    if (index > Enum.count(blockchain)-1) do
      prev_hash = KryptoCoin.Block.get_hash(prev_block)
      if prev_hash == prev_block.hash do
        true
      else
        false
      end
    else
      current_block = Enum.at(blockchain, index)
      prev_hash = KryptoCoin.Block.get_hash(prev_block)
      if (prev_block.hash == current_block.previous_hash and prev_block.index+1 == current_block.index and prev_hash == prev_block.hash) do
          validate_blockchain(blockchain, index+1, current_block)
      else
        false
      end
    end
  end

  def calculate_hash(index, previous_hash, nonce, timestamp, transactions) do
    digest = num_to_string(index) <>
              handle_empty_string(previous_hash) <>
              num_to_string(nonce) <>
              num_to_string(timestamp) <>
              concatenate_transactions(transactions, "")
    hash = KryptoCoin.HashModule.get_hash(digest)
    if (String.slice(hash, 0..@difficulty-1) == "00") do
      {nonce, hash}
    else
      calculate_hash(index, previous_hash, nonce+1, timestamp, transactions)
    end
  end

  def get_digest(block) do
    num_to_string(block.index) <>
      handle_empty_string(block.previous_hash) <>
      num_to_string(block.nonce) <>
      num_to_string(block.timestamp) <>
      concatenate_transactions(block.transactions, "")
  end

  def get_hash(block) do
    digest = get_digest(block)
    KryptoCoin.HashModule.get_hash(digest)
  end

  defp handle_empty_string(str) do
    if (str == nil) do
      ""
    else
      str
    end
  end

  defp num_to_string(num) do
    if (num == nil) do
      ""
    else
      Integer.to_string(num)
    end
  end

  def concatenate_transactions([transaction|tail], acc) do
    concatenate_transactions(tail, acc <> handle_empty_string(transaction.sender) <>
      handle_empty_string(transaction.receiver) <> Float.to_string(transaction.amount))
  end

  def concatenate_transactions([], acc) do
    acc
  end

end
