defmodule LynxListWeb.TestController do
  use LynxListWeb, :controller

  import LynxListWeb.Auth.Plugs

  plug :attempt_authentication

  def index(conn, _params) do
    # json(conn, %{foo: "bar"})
    conn
    |> put_status(500)
    |> render(LynxListWeb.ErrorView, "error.json")
  end
end
