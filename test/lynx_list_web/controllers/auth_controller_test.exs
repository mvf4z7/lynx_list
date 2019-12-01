defmodule LynxListWeb.AuthControllerTest do
  use LynxListWeb.ConnCase, async: true

  alias LynxList.Fixtures
  alias LynxList.Accounts.Token
  alias LynxListWeb.Auth

  test "GET /auth/github/request redirects to a Github webpage for authentication" do
    conn =
      build_conn()
      |> get("/auth/github/request")

    assert "https://github.com/login/oauth/authorize" <> _rest_of_path = redirected_to(conn)
  end

  test "GET /auth/github/callback should authenticate as the user associated with the authenticated github user" do
    github_id = 123
    user = Fixtures.user(%{credentials: %{github_id: github_id}})

    expected_claims =
      with {:ok, token} <- Token.generate(user),
           {:ok, claims} <- Token.verify_and_validate(token) do
        claims
      end

    actual_claims =
      build_conn()
      |> put_ueberauth_assigns(:github, github_id)
      |> get("/auth/github/callback?state=#{URI.encode_query(%{"state" => "success=/foo"})}")
      # Recyling the conn will carry the auth cookies applied forward, so that
      # we can authenticate below. This simulates the cookies persisting over
      # multiple request/response cycles, similar to a browser environment.
      |> recycle()
      |> Auth.require_authentication()
      |> Auth.get_claims()

    temporal_claim_keys = ["exp", "iat"]

    [actual_claims, expected_claims] =
      [actual_claims, expected_claims]
      |> Enum.map(&Map.drop(&1, temporal_claim_keys))

    assert actual_claims == expected_claims
  end

  test "GET /auth/github should redirect to /auth/github/request with the query string encoded and mapped to the value of the \"state\" query string parameter" do
    redirect_paths = %{
      "success" => "/foo/bar",
      "unknown" => "/baz",
      "error" => "/error-page"
    }

    redirect_uri =
      build_conn()
      |> get("/auth/github?#{URI.encode_query(redirect_paths)}")
      |> redirected_to()
      |> URI.parse()

    redirect_query_map = URI.decode_query(redirect_uri.query)

    assert redirect_uri.path == "/auth/github/request"
    assert Map.keys(redirect_query_map) == ["state"]

    assert redirect_query_map["state"]
           |> URI.decode_query() == redirect_paths
  end

  test "GET /auth/github should ignore any unknown query parameters when it builds the \"state\" query string parameter" do
    input_query_map = %{
      "success" => "/foo/bar",
      "unknown" => "/baz",
      "error" => "/error-page",
      "bad" => "value",
      "another" => "bad-value"
    }

    redirect_uri =
      build_conn()
      |> get("/auth/github?#{URI.encode_query(input_query_map)}")
      |> redirected_to()
      |> URI.parse()

    redirect_query_map = URI.decode_query(redirect_uri.query)

    assert redirect_query_map["state"]
           |> URI.decode_query() == Map.drop(input_query_map, ["bad", "another"])
  end

  test "GET /auth/github/callback should redirect to the \"success\" URL if a LynxList account exists that matches the authenticated Github user" do
    github_id = 123
    Fixtures.user(%{credentials: %{github_id: github_id}})

    query_map = %{"state" => "success=/foo/success/bar/"}
    request_uri = "/auth/github/callback?#{URI.encode_query(query_map)}"

    redirect_uri =
      build_conn()
      |> put_ueberauth_assigns(:github, github_id)
      |> get(request_uri)
      |> redirected_to()
      |> URI.parse()

    assert redirect_uri.path == "/foo/success/bar/"
  end

  test "GET /auth/github/callback should redirect to the \"uknown\" URL if a LynxList account matching the authenticated Github user does not exist" do
    query_map = %{"state" => "unknown=/foo/unknown/bar/"}
    request_uri = "/auth/github/callback?#{URI.encode_query(query_map)}"

    redirect_uri =
      build_conn()
      |> put_ueberauth_assigns(:github, 1234)
      |> get(request_uri)
      |> redirected_to()
      |> URI.parse()

    assert redirect_uri.path == "/foo/unknown/bar/"
  end

  test "GET /auth/github/callback should redirect to the \"error\" URL if github fails to authenticate the user" do
    query_map = %{"state" => "error=/foo/error/bar/"}
    request_uri = "/auth/github/callback?#{URI.encode_query(query_map)}"

    redirect_uri =
      build_conn()
      |> put_ueberauth_failure_assigns(:github)
      |> get(request_uri)
      |> redirected_to()
      |> URI.parse()

    assert redirect_uri.path == "/foo/error/bar/"
  end

  defp put_ueberauth_assigns(conn, provider, provider_user_id) do
    auth = %Ueberauth.Auth{
      provider: provider,
      uid: provider_user_id
    }

    assign(conn, :ueberauth_auth, auth)
  end

  defp put_ueberauth_failure_assigns(conn, provider) do
    failed_auth = %Ueberauth.Failure{
      errors: [],
      provider: provider
    }

    assign(conn, :ueberauth_failure, failed_auth)
  end
end
