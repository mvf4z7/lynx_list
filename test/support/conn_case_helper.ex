defmodule LynxListWeb.ConnCaseHelper do
  import Plug.Conn

  alias LynxListWeb.Auth
  alias LynxList.Accounts.{Token, User}

  @spec render_json(atom, binary, keyword) :: map
  def render_json(view, template, assigns \\ []) do
    view.render(template, assigns) |> format_json
  end

  @spec create_authed_conn(%User{}, map) :: %Plug.Conn{}
  def create_authed_conn(%User{} = user, additional_claims \\ %{}) do
    {:ok, jwt} = Token.generate(user, additional_claims)

    conn =
      Phoenix.ConnTest.build_conn()
      |> Auth.put_jwt_cookies(jwt: jwt)

    Enum.reduce(fetch_cookies(conn).cookies, conn, fn {key, value}, conn ->
      Plug.Test.put_req_cookie(conn, key, value)
    end)
  end

  @spec format_json(map) :: map
  defp format_json(data) do
    data |> Jason.encode!() |> Jason.decode!()
  end
end
