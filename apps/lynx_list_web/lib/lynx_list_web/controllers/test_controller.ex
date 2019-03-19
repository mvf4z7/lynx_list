defmodule LynxListWeb.TestController do
  use LynxListWeb, :controller

  def index(conn, _params) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, "{ \"foo\": \"bar\"}")
  end
end
