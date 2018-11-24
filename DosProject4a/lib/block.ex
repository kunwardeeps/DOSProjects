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
