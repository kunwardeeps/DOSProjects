defmodule KryptoCoin.Block do
  defstruct index: nil,
            hash: nil,
            previous_hash: nil,
            nonce: 0,
            timestamp: nil,
            transactions: []

  def initialize() do
    %KryptoCoin.Block{
      index: 0,
      timestamp: :os.system_time(:seconds)
    }
  end

  def calculate_block_hash(block) do
    %{
      index: index,
      previous_hash: previous_hash,
      nonce: nonce,
      timestamp: timestamp,
      transactions: transactions
    } = block

    KryptoCoin.HashModule.get_hash(num_to_string(index) <>
    handle_empty_string(previous_hash) <> num_to_string(nonce) <>
    num_to_string(timestamp) <> concatenate_transactions(transactions))
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

  defp concatenate_transactions(transactions) do
    if (Enum.empty?(transactions)) do
      ""
    else
      Enum.reduce(transactions, fn(x, acc) -> x <> acc end)
    end

  end
end
