defmodule DosProject4BWeb.ChartController do
  use DosProject4BWeb, :controller

  def chart(conn, _params) do
    result = :rand.uniform(10) * 10
    render(conn, "chart.html", result: result)
  end
end
