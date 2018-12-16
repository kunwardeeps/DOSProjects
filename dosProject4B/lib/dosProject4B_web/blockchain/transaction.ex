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
    type = "coinbase"
    digest = get_digest("", miner_address, amount, [], timestamp, type)
    txid = KryptoCoin.HashModule.get_hash(digest)
    signature = KryptoCoin.HashModule.sign(private_key, txid)

    %KryptoCoin.Transaction{
      id: txid,
      timestamp: timestamp,
      sender: "",
      receiver: miner_address,
      amount: amount,
      type: "coinbase",
      signature: signature,
      outputs: [
        %{txoid: "0:#{txid}", addr: miner_address, amount: amount}
      ]
    }
  end

  def get_input_utxos(utxos, amount, sender_public_key) do
    sender_utxos = Enum.filter(Map.values(utxos), fn(utxo) -> utxo.addr == sender_public_key end)
    filter_utxos(sender_utxos, amount, [])
  end

  def filter_utxos([head|tail], amount, utxo_list) do
    sum_current = Enum.reduce(utxo_list, 0.0, fn(utxo,acc) -> utxo.amount + acc end)
    if (sum_current >= amount) do
      utxo_list
    else
      if (tail == nil) do
        nil
      else
        filter_utxos(tail, amount, utxo_list ++ [head])
      end
    end
  end

  def filter_utxos([], _amount, utxo_list) do
    utxo_list
  end

  def generate_transaction(amount, wallet, receiver_pub_key, utxos) do
    timestamp = :os.system_time(:seconds)
    type = "regular"
    inputs = get_input_utxos(utxos, amount, wallet.public_key)
    left_over_amount = Enum.reduce(inputs, 0.0, fn(utxo,acc) -> utxo.amount + acc end) - amount
    digest = get_digest(wallet.public_key, receiver_pub_key, amount, inputs, timestamp, type)
    txid = KryptoCoin.HashModule.get_hash(digest)
    signature = KryptoCoin.HashModule.sign(wallet.private_key, txid)
    outputs = calculate_outputs(txid, wallet, receiver_pub_key, amount, left_over_amount)

    %KryptoCoin.Transaction{
      id: txid,
      timestamp: timestamp,
      sender: wallet.public_key,
      receiver: receiver_pub_key,
      amount: amount,
      signature: signature,
      inputs: inputs,
      outputs: outputs,
      type: type
    }
  end

  def get_digest(sender, receiver, amount, inputs, timestamp, type) do
    sender <>
    receiver <>
    type <>
    Float.to_string(amount) <>
    "#{inspect(inputs)}" <>
    Integer.to_string(timestamp)
  end

  def get_digest(transaction) do
    transaction.sender <>
    transaction.receiver <>
    transaction.type <>
    Float.to_string(transaction.amount) <>
    "#{inspect(transaction.inputs)}" <>
    Integer.to_string(transaction.timestamp)
  end

  def calculate_outputs(txid, wallet, receiver_pub_key, amount, left_over_amount) do
    if (left_over_amount == 0) do
      [
        %{txoid: "0:#{txid}", addr: receiver_pub_key, amount: amount}
      ]
    else
      [
        %{txoid: "0:#{txid}", addr: receiver_pub_key, amount: amount},
        %{txoid: "1:#{txid}", addr: wallet.public_key, amount: left_over_amount}
      ]
    end
  end

  def validate_input_outputs(transaction) do
    input_sum = Enum.reduce(transaction.inputs, 0, fn(op, acc) -> op.amount + acc end)
    output_sum = Enum.reduce(transaction.outputs, 0, fn(op, acc) -> op.amount + acc end)
    input_sum == output_sum
  end

  def validate(transaction, utxos) do
    digest = get_digest(transaction)
    txn_hash = KryptoCoin.HashModule.get_hash(digest)
    cond do
      transaction.id != txn_hash ->
        :invalid_hash
      !KryptoCoin.HashModule.verify_signature(transaction.sender, transaction.signature, txn_hash) ->
        :invalid_signature
      !validate_input_outputs(transaction) ->
        :invalid_amount
      !inputs_exist?(transaction.inputs, utxos) ->
        :invalid_transaction_inputs
      true ->
        :ok
      end
  end

  def inputs_exist?(inputs, utxos) do
    Enum.reduce(inputs, true, fn(input,acc) ->
      (Map.has_key?(utxos, input.txoid) or Map.has_key?(utxos, input.txoid)) and acc end)
  end

end
