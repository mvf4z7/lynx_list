defmodule LynxListWeb.TestController do
  use LynxListWeb, :controller

  def index(conn, _params) do
    json(conn, %{foo: "bar"})
  end
end
