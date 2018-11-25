defmodule KryptoCoin.Block do
  @difficulty 2
  defstruct index: nil,
            hash: nil,
            previous_hash: nil,
            nonce: 0,
            timestamp: nil,
            transactions: []

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
      transactions: [coinbase_txn]
    }
  end

  def generate_block(transactions, last_block) do
    timestamp = :os.system_time(:seconds)
    index = last_block.index + 1
    prev_hash = last_block.hash
    {nonce, hash} = calculate_hash(index, prev_hash, 0, timestamp, transactions)
    %KryptoCoin.Block{
      index: 0,
      nonce: nonce,
      timestamp: timestamp,
      hash: hash,
      transactions: transactions
    }
  end

  def validate(block) do
    hash = KryptoCoin.HashModule.get_hash(num_to_string(block.index) <>
      handle_empty_string(block.previous_hash) <>
      num_to_string(block.nonce) <>
      num_to_string(block.timestamp) <>
      concatenate_transactions(block.transactions, ""))
    cond do
      hash == block.hash ->
        :invalid_nonce
      true ->
        :ok
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
