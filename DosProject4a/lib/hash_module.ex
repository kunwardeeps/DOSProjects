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

  def create_keypair() do
    :crypto.generate_key(:ecdh, :secp256k1)
  end

  def sign(private_key, data) do
    :crypto.sign(:ecdsa, :sha256, data, [private_key, :secp256k1])
  end

  def verify_signature(public_key, signature, data) do
    :crypto.verify(:ecdsa, :sha256, data, signature, [public_key, :secp256k1])
  end

end
