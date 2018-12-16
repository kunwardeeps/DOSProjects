
if length(System.argv) == 2 do
  [num_nodes, num_requests] = System.argv
  Chord.Main.start(String.to_integer(num_nodes), String.to_integer(num_requests))
else
  [num_nodes, num_requests, failure_nodes] = System.argv
  Chord.Main.start(String.to_integer(num_nodes), String.to_integer(num_requests), String.to_integer(failure_nodes))
end
