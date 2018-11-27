# DosProject4.1
# COT5615: Distributed Operating Systems
This project covers part 1 of the bitcoin simulator project in which basic features of the protocol like making transactions and mining blocks are implemented. 

## Team Members:
1. Kunwardeep Singh UFID 2421-3955
2. Gayatri Behera UFID 3258-9909

##Running the test cases:
1. cd into project directory
2. mix test

Sample Output:
...................

Finished in 1.5 seconds
19 tests, 0 failures

Randomized with seed 990180

## Test Cases Implemented:
1. Verify genesis block is mined
2. Verify genesis block hash difficulty
3. Join Network and verify if genesis block is present in new node
4. Verify account utxos in all nodes are same
5. Verify initial account balance from utxos in all nodes
6. Create a transaction and verify input and output amounts
7. Create a transaction and verify inputs are consumed from utxos
8. Transfer funds and verify account balances
9. Verify transaction is broadcasted and is present in every node's pool
10. Transfer funds with invalid amount and verify balance
11. Mine a block and verify difficulty
12. Mine a block and verify hash
13. Mine a block and verify it is broadcasted in all nodes
14. Validate previous hash in blockchain
15. Validate indices in blockchain
16. Validate reward transaction in new block
17. Validate reward transaction amount
18. Validate blockchain
19. Modify transaction amount and check if blockchain is still valid
20. Create a transaction and verify set hash and generated hash are same
21. Modify a transaction and check if it fails validation

##Bonus Features

1. Both normal and coinbase transactions are implemented. On successful mining of a block, miner gets a reward amount equal to the coinbase transaction amount of that block.
2. Immutability of entire blockchain is handled by checking valid hashes, nonces and transactions in every block. If any transaction is changed in any of the block, subsequent blocks are invalidated.
3. Transactions and blocks are broadcasted just like in the Gossip protocol fully connected network.
4. Decentralization is achieved as every node has its own copy of blockchain, transaction pool and UTXOs.
