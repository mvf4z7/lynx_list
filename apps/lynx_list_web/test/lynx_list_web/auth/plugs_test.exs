defmodule LynxListWeb.Auth.PlugsTest do
  use LynxListWeb.ConnCase, async: true

  alias LynxListWeb.Auth
  alias LynxListWeb.Auth.Plugs
  alias LynxList.Accounts
  import Plug.Conn

  @valid_registration_attrs %{
    email: "someemail@foo.com",
    name: "some name",
    username: "someusername",
    credentials: %{
      password: "password"
    }
  }

  def user_fixture(registration_overrides \\ %{}) do
    {:ok, user} =
      @valid_registration_attrs
      |> Map.merge(registration_overrides, fn k, v1, v2 ->
        case k do
          :credentials -> Map.merge(v1, v2)
          _ -> v2
        end
      end)
      |> Accounts.register_user()

    user
  end

  def create_authed_conn(user) do
    {:ok, jwt} = Auth.generate_jwt(user)

    conn =
      build_conn()
      |> Plugs.put_jwt_cookies(jwt: jwt)

    Enum.reduce(fetch_cookies(conn).cookies, conn, fn {key, value}, conn ->
      Plug.Test.put_req_cookie(conn, key, value)
    end)
  end

  describe "put_jwt_cookies" do
    test "it should put the jwt payload fragment in the \"token_payload\" cookie" do
      {:ok, jwt} =
        user_fixture()
        |> Auth.generate_jwt()

      [_header, payload, _signature] = String.split(jwt, ".")

      conn =
        build_conn()
        |> Plugs.put_jwt_cookies(jwt: jwt)
        |> fetch_cookies()

      cookie = Map.get(conn.resp_cookies, "token_payload")
      assert cookie.value == payload
    end

    test "it should put the jwt header and signature fragments in the \"token_header_signature\" cookie" do
      {:ok, jwt} =
        user_fixture()
        |> Auth.generate_jwt()

      [header, _payload, signature] = String.split(jwt, ".")

      conn =
        build_conn()
        |> Plugs.put_jwt_cookies(jwt: jwt)
        |> fetch_cookies()

      cookie = Map.get(conn.resp_cookies, "token_header_signature")
      assert cookie.value == "#{header}.#{signature}"
    end

    test "it should make the token_payload cookie accessible by javascript" do
      {:ok, jwt} =
        user_fixture()
        |> Auth.generate_jwt()

      conn =
        build_conn()
        |> Plugs.put_jwt_cookies(jwt: jwt)

      cookie = Map.get(conn.resp_cookies, "token_payload")
      assert cookie.http_only == false
    end

    test "it should make the \"token_header_signature\" cookie not accessible by javascript" do
      {:ok, jwt} =
        user_fixture()
        |> Auth.generate_jwt()

      conn =
        build_conn()
        |> Plugs.put_jwt_cookies(jwt: jwt)

      cookie = Map.get(conn.resp_cookies, "token_header_signature")
      assert cookie.http_only == true
    end
  end

  describe "attempt_authentication" do
    test "it should make the tokens claims accessible via the get_claims function when passed an authenticated conn" do
      user = user_fixture()

      claims =
        user
        |> create_authed_conn()
        |> Plugs.attempt_authentication()
        |> Auth.get_claims()

      assert is_map(claims) == true
    end

    test "it should pass through an unauthenticated conn" do
      conn =
        build_conn()
        |> Plugs.attempt_authentication()

      claims = Auth.get_claims(conn)
      assert conn.halted == false
      assert conn.status == nil
      assert claims == nil
    end
  end

  describe "require_authentication" do
    test "it should make the tokens claims accessible via the get_claims function when passed an authenticated conn" do
      user = user_fixture()

      claims =
        user
        |> create_authed_conn()
        |> Plugs.attempt_authentication()
        |> Auth.get_claims()

      assert is_map(claims) == true
    end

    test "it should halt when passed an unauthenticated conn and set a 401 status" do
      conn =
        build_conn()
        |> Plugs.require_authentication()

      assert conn.halted == true
      assert conn.status == 401
      assert Auth.get_claims(conn) == nil
    end
  end

  describe "is_authenticated" do
    test "it should return true if the conn is authenticated" do
      conn =
        user_fixture()
        |> create_authed_conn()
        |> Plugs.attempt_authentication()

      assert Plugs.is_authenticated?(conn) == true
    end

    test "it should return false if the conn is not authenticated" do
      conn =
        build_conn()
        |> Plugs.attempt_authentication()

      assert Plugs.is_authenticated?(conn) == false
    end
  end
end
