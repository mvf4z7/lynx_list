defmodule LynxListWeb.Router do
  use LynxListWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", LynxListWeb do
    pipe_through :api

    get "/test", TestController, :index
  end
end
