defmodule DosProject4BWeb.TransactionController do
  use DosProject4BWeb, :controller

  def index(conn, _params) do
    render(conn, "transaction.html")
  end

  def dropDown(conn, _params) do
    result = ["a", "b", "c", "d", "e"]
    json(conn, result)
  end

  def sign(conn, params1) do
    IO.inspect(params1)
    #IO.inspect(params2)
    {pubKey, _} = Integer.parse(Map.get(params1, "pubKey"))
    IO.inspect(pubKey)
    #{txnAmt, _} = Integer.parse(Map.get(params2, "txnAmt"))
    # kd add method here
    text(conn, "ok")
  end
end
