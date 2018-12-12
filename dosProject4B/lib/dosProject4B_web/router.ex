defmodule DosProject4BWeb.Router do
  use DosProject4BWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DosProject4BWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/hello", HelloController, :index
    get "/dropDown", HelloController, :dropDown
    get "/chart", ChartController, :chart
    get "/start", ChartController, :start
    get "/stop", ChartController, :stop
    get "/transaction", TransactionController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", DosProject4BWeb do
  #   pipe_through :api
  # end
end
