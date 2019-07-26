defmodule LynxListWeb.AuthControllerTest do
  use LynxListWeb.ConnCase

  alias LynxList.Fixtures
  alias LynxList.Accounts.Token
  alias LynxListWeb.Auth

  test "GET /auth/github redirects to a Github webpage for authentication" do
    conn =
      build_conn()
      |> get("/auth/github")

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
      |> add_ueberauth_assigns(:github, github_id)
      |> get("/auth/github/callback")
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

    assert ^actual_claims = expected_claims
  end

  defp add_ueberauth_assigns(conn, provider, provider_user_id) do
    auth = %Ueberauth.Auth{
      provider: :github,
      uid: provider_user_id
    }

    assign(conn, :ueberauth_auth, auth)
  end
end
