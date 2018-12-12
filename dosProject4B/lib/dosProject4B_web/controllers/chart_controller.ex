defmodule DosProject4BWeb.ChartController do
  use DosProject4BWeb, :controller

  def chart(conn, _params) do
    result = :rand.uniform(10) * 10
    render(conn, "chart.html", result: result)
  end

  def start(conn, params) do
    IO.inspect(params)
    {nodes, _} = Integer.parse(Map.get(params, "nodes"))
    KryptoCoin.Simulator.start(nodes)
    text(conn, "ok")
  end

  def stop(conn, _params) do
    KryptoCoin.Simulator.stop()
    text(conn, "ok")
  end
end
