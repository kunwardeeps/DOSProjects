# DosProject4.1
# COT5615: Distributed Operating Systems
This project covers part 1 of the bitcoin simulator project in which basic features of the protocol like making transactions and mining blocks are implemented. 

## Team Members:
1. Kunwardeep Singh UFID 2421-3955
2. Gayatri Behera UFID 3258-9909

## Running the test cases:
1. cd into project directory
2. mix test

Sample Output:
...................

Finished in 1.5 seconds
19 tests, 0 failures

Randomized with seed 990180

## Test Cases Implemented (with their description):
1. Verify genesis block is mined
- Checks whether genesis block is created and that it is the very first block in the blockchain

2. Verify genesis block hash difficulty
- Verification of hash difficulty of the genesis block, which is set at 2

3. Join Network and verify if genesis block is present in new node
- Checks that newly created node has same copy of the blockchain (verifies presence of genesis block)

4. Verify account utxos in all nodes are same
- Verifies if UTXO copies are same in every node 

5. Verify initial account balance from utxos in all nodes
- Verifies inital balances of UTXOs from all nodes (needs to be equivalent to the coinbase amount for the node that mined genesis block, and 0 for rest of nodes)

6. Create a transaction and verify input and output amounts
- Creates a transaction; verifies the total sum of input amounts and sum of output amounts of the transaction are same.

7. Create a transaction and verify inputs are consumed from utxos
- Confirms the validity of the transaction amount i.e. falls within the available UTXO range values for the sender node.

8. Transfer funds and verify account balances
- Verifies the account balances hold expected values after the completion of a transaction.

9. Verify transaction is broadcasted and is present in every node's pool
- Checks if the broadcasted transaction exists in every node’s transaction pool.

10. Transfer funds with invalid amount and verify balance
- Ensures that if a node tries to send amount greater than the UTXOs it has (invalid amount), it will be failed by all other nodes

11. Mine a block and verify difficulty
- Checks whether the newly created block has acceptable difficulty by checking number of zeroes.

12. Mine a block and verify hash
- Confirms if the newly created block has the set hash equal to the calculated hash.

13. Mine a block and verify it is broadcasted in all nodes
- Verifies that the newly mined block exists in the blockchain held by all nodes.

14. Validate previous hash in blockchain
- Checks that hash value of a block matches the previous hash value of a subsequent block for all blocks.

15. Validate indices in blockchain
- Ensures that continuity between the blocks in the blockchain is present, by verifying the indices of the blocks.

16. Validate reward transaction in new block
- Verifies if reward is being presented to the node that has successfully mined the block and demonstrated POW.

17. Validate reward transaction amount
- Checks whether the coinbase transaction amount is valid.

18. Validate blockchain
- This test case checks for below scenarios -
	i. If for all blocks in the blockchain, the hash value using the nonce value is valid
	ii. If coinbase amount of a block is set to its expected value
	iii. If the previous hash of the current block matches with the hash of the previous block

19. Modify transaction amount and check if blockchain is still valid
- Verified whether modifying transaction amount within some prior block in the blockchain, correctly causes blockchain to lose integrity and subsequent blocks get invalid.

20. Create a transaction and verify set hash and generated hash are same
- Test if the hash of the transaction set and after re-calculation remains same

21. Modify a transaction and check if it fails validation
- Do a negative test case to check if hash validation fails after data modification



## Bonus Features

1. Both normal and coinbase transactions are implemented. On successful mining of a block, miner gets a reward amount equal to the coinbase transaction amount of that block.
2. Immutability of entire blockchain is handled by checking valid hashes, nonces and transactions in every block. If any transaction is changed in any of the block, subsequent blocks are invalidated.
3. Transactions and blocks are broadcasted just like in the Gossip protocol fully connected network.
4. Decentralization is achieved as every node has its own copy of blockchain, transaction pool and UTXOs.


## Detailed implementation details, project flow and test case details is documented in the report attached to the project.