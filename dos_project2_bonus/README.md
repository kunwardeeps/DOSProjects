# COT5615: Distributed Operating Systems
Gossip Simulator Bonus Requirement

## Team Members
1. Gayatri Behera UFID 3258-9909
2. Kunwardeep Singh UFID 2421-3955

## Running the program: 
To start the program in Unix environment, use:

time mix run proj2.exs [num_of_Nodes] [topology] [algorithm] [Initiator_nodes] [nodes_to_kill]

Algorithm parameter types:
Gossip: gossip
Push Sum: push_sum

Topology parameter types:
Full Network: full_network
Line: line
Random 2D Grid: random_2d
3D Grid: 3d
Imperfect Line: imperfect_line
Toroid/Sphere: toroid

Sample output:
real    0m3.510s
user    0m1.124s
sys     0m0.212s

The real time shows the time taken to converge, whereas user+sys is the CPU time.
