defmodule LynxListWeb.AuthController do
  use LynxListWeb, :controller

  alias LynxListWeb.Auth
  alias LynxList.Accounts

  plug Ueberauth

  def request(conn, _params) do
    conn
    |> send_resp(201, "success")
  end

  def identity_callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    # IO.inspect(auth)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, "{ \"foo\": \"bar\"}")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    %{provider: provider} = auth

    conn
    |> do_callback(provider, auth)
  end

  def create_account(conn, params) do
    {:ok, user} = Accounts.register_user(params)
    render(conn, "create.json", user: user)
  end

  defp do_callback(conn, :github, auth) do
    github_id = auth.uid
    user = Accounts.get_user_by_github_id!(github_id)
    jwt = Auth.generate_jwt_for_user(user)

    conn
    |> put_token_cookies(jwt)
    |> redirect(external: "http://localhost.com:3000/receive?token=1234")
  end

  defp put_token_cookies(conn, token) do
    [header, payload, signature] = String.split(token, ".")
    header_and_signature = "#{header}.#{signature}"

    conn
    |> put_resp_cookie("token_payload", payload, domain: ".localhost.com", http_only: false)
    |> put_resp_cookie("token_header_signature", header_and_signature,
      domain: ".localhost.com",
      http_only: true
    )
  end
end
