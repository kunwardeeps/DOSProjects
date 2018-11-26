# DosProject4.1
# COT5615: Distributed Operating Systems
Part I of Bitcoin Simulator

## Team Members
1. Kunwardeep Singh UFID 2421-3955
2. Gayatri Behera UFID 3258-9909


## Description
This is part one of the implementation of the bitcoin protocol - 
The requirement was that the primary features of the protocol be implemented, transactions made 
and subsequent blocks be mined. The same has been completed and unit test cases have been written to
verify it's successful implementation.


Test Cases cover the following scenarios:-
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

##Running the test cases:
mix test dos_project4_test.exs