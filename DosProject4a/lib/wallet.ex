defmodule KryptoCoin.Wallet do
  defstruct public_key: nil,
            private_key: nil

  def generate() do
    {pub,priv} = KryptoCoin.HashModule.create_keypair()
    public_key = pub |> Base.encode16()
    private_key = priv |> Base.encode16()
    %KryptoCoin.Wallet{
      public_key: public_key,
      private_key: private_key
    }
  end
end
