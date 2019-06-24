defmodule LynxListWeb.TestController do
  use LynxListWeb, :controller

  import LynxListWeb.Auth.Plugs

  plug :attempt_authentication
  # plug :require_authentication

  def index(conn, _params) do
    LynxListWeb.Auth.is_authenticated?(conn)

    json(conn, %{
      authenticated: LynxListWeb.Auth.is_authenticated?(conn)
    })

    # conn
    # |> put_status(500)
    # |> render(LynxListWeb.ErrorView, "error.json")
  end
end
