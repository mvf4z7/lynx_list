defmodule LynxListWeb.Router do
  use LynxListWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/auth", LynxListWeb do
    pipe_through :api

    post "/identity/callback", AuthController, :identity_callback
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/account", AuthController, :create_account
  end

  scope "/api", LynxListWeb do
    pipe_through :api

    get "/test", TestController, :index
  end
end
