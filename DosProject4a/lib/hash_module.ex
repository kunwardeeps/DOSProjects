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
    {:ok, private_key_decoded} = private_key |> Base.decode16()
    :crypto.sign(:ecdsa, :sha256, data, [private_key_decoded, :secp256k1]) |> Base.encode16()
  end

  def verify_signature(public_key, signature, data) do
    {:ok, public_key_decoded} = public_key |> Base.decode16()
    {:ok, signature_decoded} = signature |> Base.decode16()
    :crypto.verify(:ecdsa, :sha256, data, signature_decoded, [public_key_decoded, :secp256k1])
  end

end
