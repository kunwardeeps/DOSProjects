defmodule KryptoCoin.Transaction do

  defstruct id: nil,
            inputs: [],
            outputs: [],
            signature: nil,
            sender: nil,
            receiver: nil,
            amount: 0.0,
            type: "regular",
            timestamp: nil

  def generate_coinbase(amount, miner_address, private_key) do
    timestamp = :os.system_time(:seconds)
    txid = KryptoCoin.HashModule.get_hash(miner_address <> Float.to_string(amount))
    signature = KryptoCoin.HashModule.sign(private_key, txid) |> Base.encode16

    %KryptoCoin.Transaction{
      id: txid,
      timestamp: timestamp,
      sender: nil,
      receiver: miner_address,
      amount: amount,
      type: "coinbase",
      signature: signature,
      outputs: [
        %{txoid: "0:#{txid}", addr: miner_address, amount: amount}
      ]
    }
  end

  def get_input_utxos([head|tail], amount, utxo_list) do
    if (Enum.sum(utxo_list) >= amount) do
      utxo_list
    else
      if (tail == nil) do
        nil
      else
        get_input_utxos(tail, amount, utxo_list ++ head)
      end
    end
  end

  def generate_transaction(amount, wallet, receiver_pub_key) do
    timestamp = :os.system_time(:seconds)
    txid = KryptoCoin.HashModule.get_hash(wallet.public_key <> receiver_pub_key <> Float.to_string(amount))
    signature = KryptoCoin.HashModule.sign(wallet.private_key, txid) |> Base.encode16
    inputs = get_input_utxos(wallet.utxos, amount, [List.first(wallet.utxos)])
    left_over_amount = Enum.sum(inputs) - amount

    %KryptoCoin.Transaction{
      id: txid,
      timestamp: timestamp,
      sender: wallet.public_key,
      receiver: receiver_pub_key,
      amount: amount,
      signature: signature,
      inputs: get_input_utxos(wallet.utxos, amount, [List.first(wallet.utxos)]),
      outputs: calculate_outputs(wallet, receiver_pub_key, amount, left_over_amount)
    }
  end

  def calculate_outputs(wallet, receiver_pub_key, amount, left_over_amount) do
    if (left_over_amount == 0) do
      [
        %{addr: receiver_pub_key, amount: amount}
      ]
    else
      [
        %{addr: receiver_pub_key, amount: amount},
        %{addr: wallet.public_key, amount: left_over_amount}
      ]
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

end
