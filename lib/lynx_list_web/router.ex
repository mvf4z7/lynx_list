defmodule LynxListWeb.Router do
  use LynxListWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/auth", LynxListWeb do
    pipe_through :api

    post "/identity/callback", AuthController, :identity_callback
    get "/:provider", AuthController, :redirect_to_provider
    get "/:provider/request", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/account", AuthController, :create_account
  end

  scope "/api", LynxListWeb do
    pipe_through :api

    resources "/link-records", LinkRecordController, only: [:show, :create]

    get "/test", TestController, :index
  end
end
