[numNodes,topology,algorithm,start_nodes] = System.argv
GossipPushSum.Main.start(String.to_integer(numNodes), topology, algorithm, String.to_integer(start_nodes))
