defmodule DosProject4BWeb.TransactionController do
  use DosProject4BWeb, :controller

  def index(conn, _params) do
    render(conn, "transaction.html")
  end

  def dropDown(conn, _params) do
    result = KryptoCoin.Registry.get_all()
    json(conn, result)
  end

  def transact(conn, params) do
    IO.inspect(params)
    %{"from" => from, "to" => to, "amount" => amount} = params
    from_pid = KryptoCoin.Registry.get(from)
    transaction = KryptoCoin.Node.send_funds(from_pid, to, amount)
    if transaction == :insufficient_funds do
      json(conn, %{"status" => "Insufficient Funds", "id" => nil, "signature" => nil})
    else
      json(conn, %{"status" => "Successful", "id" => transaction.id, "signature" => transaction.signature})
    end
  end
end
