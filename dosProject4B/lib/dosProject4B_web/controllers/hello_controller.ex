defmodule DosProject4BWeb.HelloController do
  use DosProject4BWeb, :controller

  def index(conn, _params) do
    result = KryptoCoin.ChartMetrics.get_data()
    json(conn, result)
  end
end
