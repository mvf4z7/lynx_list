defmodule LynxListWeb.AuthTest do
  use LynxListWeb.ConnCase, async: true

  alias LynxListWeb.Auth
  alias LynxList.Accounts.Token
  alias LynxList.Fixtures
  import Plug.Conn

  def create_authed_conn(user) do
    {:ok, jwt} = Token.generate(user)

    conn =
      build_conn()
      |> Auth.put_jwt_cookies(jwt: jwt)

    Enum.reduce(fetch_cookies(conn).cookies, conn, fn {key, value}, conn ->
      Plug.Test.put_req_cookie(conn, key, value)
    end)
  end

  describe "put_jwt_cookies" do
    test "it should put the jwt payload fragment in the \"token_payload\" cookie" do
      {:ok, jwt} =
        Fixtures.user()
        |> Token.generate()

      [_header, payload, _signature] = String.split(jwt, ".")

      conn =
        build_conn()
        |> Auth.put_jwt_cookies(jwt: jwt)
        |> fetch_cookies()

      cookie = Map.get(conn.resp_cookies, "token_payload")
      assert cookie.value == payload
    end

    test "it should put the jwt header and signature fragments in the \"token_header_signature\" cookie" do
      {:ok, jwt} =
        Fixtures.user()
        |> Token.generate()

      [header, _payload, signature] = String.split(jwt, ".")

      conn =
        build_conn()
        |> Auth.put_jwt_cookies(jwt: jwt)
        |> fetch_cookies()

      cookie = Map.get(conn.resp_cookies, "token_header_signature")
      assert cookie.value == "#{header}.#{signature}"
    end

    test "it should make the token_payload cookie accessible by javascript" do
      {:ok, jwt} =
        Fixtures.user()
        |> Token.generate()

      conn =
        build_conn()
        |> Auth.put_jwt_cookies(jwt: jwt)

      cookie = Map.get(conn.resp_cookies, "token_payload")
      assert cookie.http_only == false
    end

    test "it should make the \"token_header_signature\" cookie not accessible by javascript" do
      {:ok, jwt} =
        Fixtures.user()
        |> Token.generate()

      conn =
        build_conn()
        |> Auth.put_jwt_cookies(jwt: jwt)

      cookie = Map.get(conn.resp_cookies, "token_header_signature")
      assert cookie.http_only == true
    end
  end

  describe "attempt_authentication" do
    test "it should make the tokens claims accessible via the get_claims function when passed an authenticated conn" do
      user = Fixtures.user()

      claims =
        user
        |> create_authed_conn()
        |> Auth.attempt_authentication()
        |> Auth.get_claims()

      assert is_map(claims) == true
    end

    test "it should make the User struct accessible via the get_user function when the :load_user option is true" do
      user = Fixtures.user()

      conn =
        user
        |> create_authed_conn()
        |> Auth.attempt_authentication(load_user: true)

      assert user == Auth.get_user(conn)
    end

    test "it should not fetch the User struct by default " do
      user = Fixtures.user()

      conn =
        user
        |> create_authed_conn()
        |> Auth.attempt_authentication()

      assert Auth.get_user(conn) == nil
    end

    test "it should not fetch the User struct when the load_user option is false" do
      user = Fixtures.user()

      conn =
        user
        |> create_authed_conn()
        |> Auth.attempt_authentication(load_user: false)

      assert Auth.get_user(conn) == nil
    end

    test "it should pass through an unauthenticated conn" do
      conn =
        build_conn()
        |> Auth.attempt_authentication()

      claims = Auth.get_claims(conn)
      assert conn.halted == false
      assert conn.status == nil
      assert claims == nil
    end
  end

  describe "require_authentication" do
    test "it should make the tokens claims accessible via the get_claims function when passed an authenticated conn" do
      user = Fixtures.user()

      claims =
        user
        |> create_authed_conn()
        |> Auth.attempt_authentication()
        |> Auth.get_claims()

      assert is_map(claims) == true
    end

    test "it should halt when passed an unauthenticated conn and set a 401 status" do
      conn =
        build_conn()
        |> Auth.require_authentication()

      assert conn.halted == true
      assert conn.status == 401
      assert Auth.get_claims(conn) == nil
    end
  end

  describe "is_authenticated" do
    test "it should return true if the conn is authenticated" do
      conn =
        Fixtures.user()
        |> create_authed_conn()
        |> Auth.attempt_authentication()

      assert Auth.is_authenticated?(conn) == true
    end

    test "it should return false if the conn is not authenticated" do
      conn =
        build_conn()
        |> Auth.attempt_authentication()

      assert Auth.is_authenticated?(conn) == false
    end
  end
end
