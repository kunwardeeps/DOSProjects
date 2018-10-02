# COT5615: Distributed Operating Systems
Gossip Simulator

## Team Members
1. Gayatri Behera UFID 3258-9909
2. Kunwardeep Singh UFID 2421-3955

## What is working
- Both algorithms and all topologies are working under given conditions mentioned in next section.
- In some cases, nodes may get isolated. In such cases, we are keeping a track of times by which the isolated node is not able to find any neighbours. This has been set to 50 and if it reaches this limit, process is killed.
- Gossip algorithm is working more robustly while push sum sometimes reaches deadlock

