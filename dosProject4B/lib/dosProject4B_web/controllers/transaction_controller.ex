defmodule DosProject4BWeb.TransactionController do
  use DosProject4BWeb, :controller

  def index(conn, _params) do
    render(conn, "transaction.html")
  end

  def dropDown(conn, _params) do
    result = KryptoCoin.Registry.get_all()
    json(conn, result)
  end

  def gettransact(conn, params) do
    IO.inspect(params)
    %{"amount" => amount, "from" => from, "to" => to} = params
    from_pid = KryptoCoin.Registry.get(from)
    {amount_int, _} = Integer.parse(amount)
    transaction = KryptoCoin.Node.send_funds(from_pid, to, amount_int/1)
    new_balance = KryptoCoin.Node.get_balance(from_pid)
    if transaction == :insufficient_funds do
      IO.inspect(transaction)
      json(conn, %{"status" => "Insufficient Funds", "id" => nil, "signature" => nil, "balance" => new_balance})
    else
      json(conn, %{"status" => "Successful", "id" => transaction.id, "signature" => transaction.signature, "balance" => new_balance})
    end
  end

  def getbalance(conn, params) do
    public_key = Map.get(params, "publicKey")
    pid = KryptoCoin.Registry.get(public_key)
    result = KryptoCoin.Node.get_balance(pid)
    json(conn, result)
  end
end
