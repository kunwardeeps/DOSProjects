# COT5615: Distributed Operating Systems
Chord Protocol for Peer 2 Peer

## Running the program:
To start the program, use:
mix run proj3.exs [num_of_Nodes] [num_of_Requests]

For bonus section implementation:
mix run proj3.exs [num_of_Nodes] [num_of_Requests] [num_of_Nodes_to_fail]

Sample Output if @debug is false:
"Average hops = 1.4865"

## What is working
Chord Algortithm is working upto certain number of nodes. Since m is fixed and set as 16, maximum value for nodes can be upto 2^16. However, timeouts can occur for large values of n. 
For the bonus part, number of failure nodes are specified at the command line and are randomly destroyed during the program execution. 
To fetch logs, set @debug annotation to true in main.ex file.

## Largest Network working
The largest network that works properly is of count 1500 with 1 request per node.
