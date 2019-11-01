defmodule LynxListWeb.TestController do
  use LynxListWeb, :controller

  # plug :attempt_authentication
  plug :require_authentication, load_user: true

  def index(conn, _params) do
    is_authenticated?(conn)

    user = get_user(conn)
    IO.inspect(user)

    json(conn, %{
      authenticated: is_authenticated?(conn)
    })

    # conn
    # |> put_status(500)
    # |> render(LynxListWeb.ErrorView, "error.json")
  end
end
