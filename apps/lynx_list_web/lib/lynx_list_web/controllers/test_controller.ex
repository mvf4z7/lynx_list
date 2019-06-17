defmodule LynxListWeb.TestController do
  use LynxListWeb, :controller

  import LynxListWeb.Auth.Plugs

  plug :attempt_authentication

  def index(conn, _params) do
    json(conn, %{foo: "bar"})
  end
end
