defmodule KryptoCoin.Test do
  use ExUnit.Case
  doctest KryptoCoin.Node

  test "1. Verify genesis block is mined" do
    KryptoCoin.Registry.start_link()
    {_, pid1} = KryptoCoin.Node.start_link(nil)
    blockchain = KryptoCoin.Node.get_block_chain(pid1)
    assert blockchain != nil
    genesis = Enum.at(blockchain, 0)
    assert genesis != nil
    assert genesis.index == 0
  end

  test "2. Verify genesis block hash difficulty" do
    KryptoCoin.Registry.start_link()
    {_, pid1} = KryptoCoin.Node.start_link(nil)
    blockchain = KryptoCoin.Node.get_block_chain(pid1)
    genesis = Enum.at(blockchain, 0)
    assert String.slice(genesis.hash, 0, KryptoCoin.Block.get_difficulty()) == String.duplicate("0", KryptoCoin.Block.get_difficulty())
  end

  test "3. Join Network and verify if genesis block is present in new node" do
    KryptoCoin.Registry.start_link()
    {_, pid1} = KryptoCoin.Node.start_link(nil)
    {_, pid2} = KryptoCoin.Node.start_link(pid1)
    blockchain1 = KryptoCoin.Node.get_block_chain(pid1)
    genesis1 = Enum.at(blockchain1, 0)
    blockchain2 = KryptoCoin.Node.get_block_chain(pid2)
    genesis2 = Enum.at(blockchain2, 0)
    assert genesis1.hash == genesis2.hash
  end

  test "4. Verify account utxos in all nodes are same" do
    KryptoCoin.Registry.start_link()
    {_, pid1} = KryptoCoin.Node.start_link(nil)
    {_, pid2} = KryptoCoin.Node.start_link(pid1)
    {_, pid3} = KryptoCoin.Node.start_link(pid1)
    utxos1 = KryptoCoin.Node.get_utxos(pid1)
    utxos2 = KryptoCoin.Node.get_utxos(pid2)
    utxos3 = KryptoCoin.Node.get_utxos(pid3)
    assert utxos1 == utxos2 and utxos2 == utxos3
  end

  test "5. Verify initial account balance from utxos in all nodes" do
    KryptoCoin.Registry.start_link()
    {_, pid1} = KryptoCoin.Node.start_link(nil)
    {_, pid2} = KryptoCoin.Node.start_link(pid1)
    {_, pid3} = KryptoCoin.Node.start_link(pid1)
    balance1 = KryptoCoin.Node.get_balance(pid1)
    balance2 = KryptoCoin.Node.get_balance(pid2)
    balance3 = KryptoCoin.Node.get_balance(pid3)
    assert balance1 == KryptoCoin.Node.get_coinbase_amount()
    assert balance2 == 0.0
    assert balance3 == 0.0
  end

  test "6. Create a transaction and verify input and output amounts" do
    KryptoCoin.Registry.start_link()
    {_, pid1} = KryptoCoin.Node.start_link(nil)
    {_, pid2} = KryptoCoin.Node.start_link(pid1)
    KryptoCoin.Node.start_link(pid1)
    receiver_public_key = KryptoCoin.Node.get_public_key(pid2)
    transaction = KryptoCoin.Node.send_funds(pid1, receiver_public_key, 10.0)
    assert KryptoCoin.Transaction.validate_input_outputs(transaction)
  end

  test "7. Create a transaction and verify inputs are consumed from utxos" do
    KryptoCoin.Registry.start_link()
    {_, pid1} = KryptoCoin.Node.start_link(nil)
    {_, pid2} = KryptoCoin.Node.start_link(pid1)
    KryptoCoin.Node.start_link(pid1)
    receiver_public_key = KryptoCoin.Node.get_public_key(pid2)
    transaction = KryptoCoin.Node.send_funds(pid1, receiver_public_key, 10.0)
    utxos = KryptoCoin.Node.get_utxos(pid1)
    assert !KryptoCoin.Transaction.inputs_exist?(transaction.inputs, utxos)
  end

  test "8. Transfer funds and verify account balances" do
    KryptoCoin.Registry.start_link()
    {_, pid1} = KryptoCoin.Node.start_link(nil)
    {_, pid2} = KryptoCoin.Node.start_link(pid1)
    {_, pid3} = KryptoCoin.Node.start_link(pid1)
    receiver_public_key = KryptoCoin.Node.get_public_key(pid2)
    KryptoCoin.Node.send_funds(pid1, receiver_public_key, 10.0)
    balance1 = KryptoCoin.Node.get_balance(pid1)
    balance2 = KryptoCoin.Node.get_balance(pid2)
    balance3 = KryptoCoin.Node.get_balance(pid3)
    assert balance1 == 90.0
    assert balance2 == 10.0
    assert balance3 == 0.0
  end

  test "9. Verify transaction is broadcasted and is present in every node's pool" do
    KryptoCoin.Registry.start_link()
    {_, pid1} = KryptoCoin.Node.start_link(nil)
    {_, pid2} = KryptoCoin.Node.start_link(pid1)
    {_, pid3} = KryptoCoin.Node.start_link(pid1)
    receiver_public_key = KryptoCoin.Node.get_public_key(pid2)
    transaction = KryptoCoin.Node.send_funds(pid1, receiver_public_key, 10.0)
    pool1 = KryptoCoin.Node.get_transaction_pool(pid1)
    pool2 = KryptoCoin.Node.get_transaction_pool(pid2)
    pool3 = KryptoCoin.Node.get_transaction_pool(pid3)
    assert Map.has_key?(pool1, transaction.id)
    assert Map.has_key?(pool2, transaction.id)
    assert Map.has_key?(pool3, transaction.id)
  end

  test "10. Transfer funds with invalid amount and verify balance" do
    KryptoCoin.Registry.start_link()
    {_, pid1} = KryptoCoin.Node.start_link(nil)
    {_, pid2} = KryptoCoin.Node.start_link(pid1)
    {_, pid3} = KryptoCoin.Node.start_link(pid1)
    receiver_public_key = KryptoCoin.Node.get_public_key(pid2)
    result = KryptoCoin.Node.send_funds(pid1, receiver_public_key, 1000.0)
    balance1 = KryptoCoin.Node.get_balance(pid1)
    balance2 = KryptoCoin.Node.get_balance(pid2)
    balance3 = KryptoCoin.Node.get_balance(pid3)

    assert result == :insufficient_funds
    assert balance1 == 100.0
    assert balance2 == 0.0
    assert balance3 == 0.0
  end

  test "11. Mine a block and verify difficulty" do
    KryptoCoin.Registry.start_link()
    {_, pid1} = KryptoCoin.Node.start_link(nil)
    {_, pid2} = KryptoCoin.Node.start_link(pid1)
    KryptoCoin.Node.start_link(pid1)
    receiver_public_key = KryptoCoin.Node.get_public_key(pid2)
    KryptoCoin.Node.send_funds(pid1, receiver_public_key, 10.0)
    block = KryptoCoin.Node.mine_block(pid1)
    assert String.slice(block.hash, 0, KryptoCoin.Block.get_difficulty()) == String.duplicate("0", KryptoCoin.Block.get_difficulty())
  end

  test "12. Mine a block and verify hash" do
    KryptoCoin.Registry.start_link()
    {_, pid1} = KryptoCoin.Node.start_link(nil)
    {_, pid2} = KryptoCoin.Node.start_link(pid1)
    KryptoCoin.Node.start_link(pid1)
    receiver_public_key = KryptoCoin.Node.get_public_key(pid2)
    KryptoCoin.Node.send_funds(pid1, receiver_public_key, 10.0)
    block = KryptoCoin.Node.mine_block(pid1)

    assert block.hash == KryptoCoin.Block.get_hash(block)
  end

  test "13. Mine a block and verify it is broadcasted in all nodes" do
    KryptoCoin.Registry.start_link()
    {_, pid1} = KryptoCoin.Node.start_link(nil)
    {_, pid2} = KryptoCoin.Node.start_link(pid1)
    {_, pid3} = KryptoCoin.Node.start_link(pid1)
    receiver_public_key = KryptoCoin.Node.get_public_key(pid2)
    KryptoCoin.Node.send_funds(pid1, receiver_public_key, 10.0)
    block = KryptoCoin.Node.mine_block(pid1)
    blockchain1 = KryptoCoin.Node.get_block_chain(pid1)
    blockchain2 = KryptoCoin.Node.get_block_chain(pid2)
    blockchain3 = KryptoCoin.Node.get_block_chain(pid3)
    assert Enum.at(blockchain1, 1).hash == block.hash
    assert Enum.at(blockchain2, 1).hash == block.hash
    assert Enum.at(blockchain3, 1).hash == block.hash
  end

  test "14. Validate previous hash in blockchain" do
    KryptoCoin.Registry.start_link()
    {_, pid1} = KryptoCoin.Node.start_link(nil)
    {_, pid2} = KryptoCoin.Node.start_link(pid1)
    KryptoCoin.Node.start_link(pid1)
    receiver_public_key = KryptoCoin.Node.get_public_key(pid2)
    KryptoCoin.Node.send_funds(pid1, receiver_public_key, 10.0)
    KryptoCoin.Node.mine_block(pid1)
    blockchain = KryptoCoin.Node.get_block_chain(pid1)
    assert Enum.at(blockchain, 0).hash == Enum.at(blockchain, 1).previous_hash
  end

  test "15. Validate indices in blockchain" do
    KryptoCoin.Registry.start_link()
    {_, pid1} = KryptoCoin.Node.start_link(nil)
    {_, pid2} = KryptoCoin.Node.start_link(pid1)
    KryptoCoin.Node.start_link(pid1)
    receiver_public_key = KryptoCoin.Node.get_public_key(pid2)
    KryptoCoin.Node.send_funds(pid1, receiver_public_key, 10.0)
    KryptoCoin.Node.mine_block(pid1)
    blockchain = KryptoCoin.Node.get_block_chain(pid1)
    assert Enum.at(blockchain, 0).index+1 == Enum.at(blockchain, 1).index
  end

  test "16. Validate reward transaction in new block" do
    KryptoCoin.Registry.start_link()
    {_, pid1} = KryptoCoin.Node.start_link(nil)
    {_, pid2} = KryptoCoin.Node.start_link(pid1)
    KryptoCoin.Node.start_link(pid1)
    receiver_public_key = KryptoCoin.Node.get_public_key(pid2)
    KryptoCoin.Node.send_funds(pid1, receiver_public_key, 10.0)
    block = KryptoCoin.Node.mine_block(pid1)
    coinbase = KryptoCoin.Block.get_coinbase(block)
    assert coinbase != nil
  end

  test "17. Validate reward transaction amount" do
    KryptoCoin.Registry.start_link()
    {_, pid1} = KryptoCoin.Node.start_link(nil)
    {_, pid2} = KryptoCoin.Node.start_link(pid1)
    KryptoCoin.Node.start_link(pid1)
    receiver_public_key = KryptoCoin.Node.get_public_key(pid2)
    KryptoCoin.Node.send_funds(pid1, receiver_public_key, 10.0)
    block = KryptoCoin.Node.mine_block(pid1)
    coinbase = KryptoCoin.Block.get_coinbase(block)
    assert coinbase.amount <= KryptoCoin.Node.get_coinbase_amount()
  end

  test "18. Validate blockchain" do
    KryptoCoin.Registry.start_link()
    {_, pid1} = KryptoCoin.Node.start_link(nil)
    {_, pid2} = KryptoCoin.Node.start_link(pid1)
    KryptoCoin.Node.start_link(pid1)
    receiver_public_key = KryptoCoin.Node.get_public_key(pid2)
    KryptoCoin.Node.send_funds(pid1, receiver_public_key, 10.0)
    block = KryptoCoin.Node.mine_block(pid1)
    blockchain = KryptoCoin.Node.get_block_chain(pid1)
    assert KryptoCoin.Block.validate(block, blockchain)
  end

  test "19. Modify transaction amount and check if blockchain is still valid" do
    KryptoCoin.Registry.start_link()
    {_, pid1} = KryptoCoin.Node.start_link(nil)
    {_, pid2} = KryptoCoin.Node.start_link(pid1)
    KryptoCoin.Node.start_link(pid1)
    receiver_public_key = KryptoCoin.Node.get_public_key(pid2)
    KryptoCoin.Node.send_funds(pid1, receiver_public_key, 10.0)
    block = KryptoCoin.Node.mine_block(pid1)
    blockchain = KryptoCoin.Node.get_block_chain(pid1)
    first_block = Enum.at(blockchain, 0)
    first_block_transactions = first_block.transactions
    first_transaction = Enum.at(first_block_transactions, 0)
    modified_transaction = %{first_transaction | amount: 1000.0}
    modified_transactions = List.replace_at(first_block_transactions, 0, modified_transaction)
    modified_block = %{first_block | transactions: modified_transactions}
    modified_blockchain = List.replace_at(blockchain, 0, modified_block)
    assert KryptoCoin.Block.validate(block, modified_blockchain) == :invalid_blockchain
  end

  test "20. Create a transaction and verify set hash and generated hash are same" do
    KryptoCoin.Registry.start_link()
    {_, pid1} = KryptoCoin.Node.start_link(nil)
    {_, pid2} = KryptoCoin.Node.start_link(pid1)
    KryptoCoin.Node.start_link(pid1)
    receiver_public_key = KryptoCoin.Node.get_public_key(pid2)
    transaction = KryptoCoin.Node.send_funds(pid1, receiver_public_key, 10.0)
    digest = KryptoCoin.Transaction.get_digest(transaction)
    assert transaction.id == KryptoCoin.HashModule.get_hash(digest)
  end

  test "21. Modify a transaction and check if it fails validation" do
    KryptoCoin.Registry.start_link()
    {_, pid1} = KryptoCoin.Node.start_link(nil)
    {_, pid2} = KryptoCoin.Node.start_link(pid1)
    KryptoCoin.Node.start_link(pid1)
    receiver_public_key = KryptoCoin.Node.get_public_key(pid2)
    transaction = KryptoCoin.Node.send_funds(pid1, receiver_public_key, 10.0)
    utxos = KryptoCoin.Node.get_utxos(pid1)
    new_transaction = %{transaction | amount: 1000.0}
    assert KryptoCoin.Transaction.validate(new_transaction, utxos) == :invalid_hash
  end

end
