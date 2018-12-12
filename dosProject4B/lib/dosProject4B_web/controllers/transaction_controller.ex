defmodule DosProject4BWeb.TransactionController do
  use DosProject4BWeb, :controller

  def index(conn, _params) do
    render(conn, "transaction.html")
  end

  def dropDown(conn, _params) do
    text(conn, "ok")
  end
end
