defmodule Chord.HashModule do

  def get_node_id(node_name, m) do
    {val, _} = :crypto.hash(:sha, node_name)
    |> binary_part(0, div(m,8))
    |> Base.encode16
    |> Integer.parse(16)

    val
  end

  def generate_random_string(length) do
    list = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789" |> String.split("")
    (1..length)
    |> Enum.reduce([], fn(_, acc) -> [Enum.random(list) | acc] end)
    |> Enum.join("")
  end
end
