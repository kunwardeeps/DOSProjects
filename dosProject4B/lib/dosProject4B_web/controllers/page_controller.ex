defmodule DosProject4BWeb.PageController do
  use DosProject4BWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
