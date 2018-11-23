defmodule KryptoCoin.Wallet do
  defstruct public_key: nil,
            private_key: nil,
            utxos: []

  def generate(coinbase_amount) do
    {pub,priv} = KryptoCoin.HashModule.create_keypair()
    %KryptoCoin.Wallet{
      public_key: pub |> Base.encode16,
      private_key: priv |> Base.encode16,
      utxos: [coinbase_amount]
    }
  end

  def add_utxo(wallet, amount) do
    %{wallet | utxos: wallet.utxos ++ [amount]}
  end

  def remove_utxo(wallet, amount) do
    %{wallet | utxos: wallet.utxos -- [amount]}
  end

  def update_utxos(wallet, amounts, new_amount) do
    new_utxos = wallet.utxos -- amounts
    %{wallet | utxos: new_utxos ++ [new_amount]}
  end

  def get_balance(wallet) do
    utxos = wallet.utxos
    Enum.sum(utxos)
  end
end
