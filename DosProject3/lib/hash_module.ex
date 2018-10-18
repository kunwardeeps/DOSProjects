defmodule Chord.HashModule do

  def get_node_id(node_name, m) do
    {val, _} = :crypto.hash(:sha, node_name)
    |> binary_part(0, m)
    |> Base.encode16
    |> Integer.parse(16)
    val
  end

end
