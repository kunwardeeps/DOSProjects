defmodule KryptoCoin.HashModule do

  def get_hash(str) do
    :crypto.hash(:sha256, str) |> Base.encode16 |> String.downcase
  end

  def generate_random_string(length) do
    list = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789" |> String.split("")
    (1..length)
    |> Enum.reduce([], fn(_, acc) -> [Enum.random(list) | acc] end)
    |> Enum.join("")
  end
end
