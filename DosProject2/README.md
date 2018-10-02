# COT5615: Distributed Operating Systems
Gossip Simulator

## Team Members
1. Gayatri Behera UFID 3258-9909
2. Kunwardeep Singh UFID 2421-3955

## What is working
- Both algorithms and all topologies are working under given conditions mentioned in next section.
- In some cases, nodes may get isolated. In such cases, we are keeping a track of times by which the isolated node is not able to find any neighbours. This has been set to 50 and if it reaches this limit, process is killed.
- Out of all topologies, line is the worst performer as it is more likely to lose neighbours.
- Overall, greater the number of neighbours, better is the convergence time.
- Gossip algorithm is working more robustly while push sum sometimes reaches deadlock
- For bonus requirements, a failure model is implemented in such a way that total number of nodes to be failed can be mentioned via command line

## Largest network working for given topologies and algorithms:

1. Gossip: 
1.1. Full Network: 5000
1.2. 3D Grid: 70000
1.3. Random 2D Grid: 3000
1.4. Sphere/Toroid: 40000
1.5. Line: 15000
1.6. Imperfect Line: 5000

2. Push Sum: 
2.1. Full Network: 3000
2.2. 3D Grid: 2000
2.3. Random 2D Grid: 2000
2.4. Sphere/Toroid: 4000
2.5. Line: 300
2.6. Imperfect Line:3000

##Running the program: 
To start the program in Unix environment, use:

time mix run proj2.exs [num_of_Nodes] [topology] [algorithm]

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
