defmodule LynxListWeb.Auth.PlugsTest do
  use LynxListWeb.ConnCase, async: true

  alias LynxListWeb.Auth.Plugs
  alias LynxListWeb.Auth.JWT
  import Plug.Conn

  describe "put_jwt_cookies" do
    test "it should put the jwt payload fragment in the \"token_payload\" cookie" do
      jwt = JWT.generate_and_sign!()
      [_header, payload, _signature] = String.split(jwt, ".")

      conn =
        build_conn()
        |> Plugs.put_jwt_cookies(jwt: jwt)
        |> fetch_cookies()

      cookie = Map.get(conn.resp_cookies, "token_payload")
      assert cookie.value == payload
    end

    test "it should put the jwt header and signature fragments in the \"token_header_signature\" cookie" do
      jwt = JWT.generate_and_sign!()
      [header, _payload, signature] = String.split(jwt, ".")

      conn =
        build_conn()
        |> Plugs.put_jwt_cookies(jwt: jwt)
        |> fetch_cookies()

      cookie = Map.get(conn.resp_cookies, "token_header_signature")
      assert cookie.value == "#{header}.#{signature}"
    end

    test "it should make the token_payload cookie accessible by javascript" do
      jwt = JWT.generate_and_sign!()

      conn =
        build_conn()
        |> Plugs.put_jwt_cookies(jwt: jwt)

      cookie = Map.get(conn.resp_cookies, "token_payload")
      assert cookie.http_only == false
    end

    test "it should make the \"token_header_signature\" cookie not accessible by javascript" do
      jwt = JWT.generate_and_sign!()

      conn =
        build_conn()
        |> Plugs.put_jwt_cookies(jwt: jwt)

      cookie = Map.get(conn.resp_cookies, "token_header_signature")
      assert cookie.http_only == true
    end
  end

  describe "attempt_authentication" do
    test "" do
    end
  end
end
