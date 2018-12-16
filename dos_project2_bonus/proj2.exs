[numNodes,topology,algorithm,start_nodes,fail_nodes] = System.argv
GossipPushSum.Main.start(String.to_integer(numNodes), topology, algorithm, String.to_integer(start_nodes), String.to_integer(fail_nodes))
