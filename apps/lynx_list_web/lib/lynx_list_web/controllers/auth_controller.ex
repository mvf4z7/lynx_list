defmodule LynxListWeb.AuthController do
  use LynxListWeb, :controller

  alias LynxList.Accounts

  plug Ueberauth

  def request(conn, _params) do
    conn
    |> send_resp(201, "success")
  end

  def identity_callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    IO.inspect(auth)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, "{ \"foo\": \"bar\"}")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    %{provider: provider} = auth

    conn
    |> put_token_cookies
    |> do_callback(provider, auth)
  end

  def create_account(conn, params) do
    {:ok, user} = Accounts.register_user(params)
    IO.inspect(user)
    render(conn, "create.json", user: user)
  end

  defp do_callback(conn, :github, auth) do
    IO.inspect(auth)

    conn
    # |> put_resp_content_type("application/json")
    |> redirect(external: "http://localhost.com:3000/receive?token=1234")
  end

  defp put_token_cookies(conn) do
    payload =
      Jason.encode!(%{
        id: 1,
        name: "John Doe",
        admin: false
      })

    conn
    |> put_resp_cookie("token_payload", payload, domain: ".localhost.com", http_only: false)
    |> put_resp_cookie("token_header_signature", "header_and_signature",
      domain: ".localhost.com",
      http_only: true
    )
  end
end
