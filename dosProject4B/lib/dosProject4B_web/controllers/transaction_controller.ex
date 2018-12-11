defmodule DosProject4BWeb.TransactionController do
  use DosProject4BWeb, :controller

  def index(conn, _params) do
    render(conn, "chart.html")
  end
end
