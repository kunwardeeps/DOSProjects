defmodule DosProject4BWeb.HelloController do
  use DosProject4BWeb, :controller

  def index(conn, _params) do
    result = :rand.uniform(10) * 10
    text(conn, result)
  end
end
