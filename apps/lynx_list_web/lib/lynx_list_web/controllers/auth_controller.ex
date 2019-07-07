defmodule LynxListWeb.AuthController do
  use LynxListWeb, :controller

  alias LynxListWeb.Auth
  alias LynxList.Accounts

  plug Ueberauth
  @lynx_list_client_url Application.get_env(:lynx_list_web, :lynx_list_client_url)

  def request(conn, _params) do
    conn
    |> send_resp(201, "success")
  end

  def identity_callback(%{assigns: %{ueberauth_auth: _auth}} = conn, _params) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, "{ \"foo\": \"bar\"}")
  end

  def callback(conn, %{"provider" => provider} = params) do
    %{assigns: %{ueberauth_auth: auth}} = conn
    redirect_path = Map.get(params, "state", "/receive")

    conn
    |> do_callback(provider, auth)
    |> redirect(external: "#{@lynx_list_client_url}#{redirect_path}")
  end

  def create_account(conn, params) do
    {:ok, user} = Accounts.register_user(params)
    render(conn, "create.json", user: user)
  end

  defp do_callback(conn, "github", auth) do
    github_id = auth.uid
    user = Accounts.get_user_by_github_id!(github_id)
    {:ok, jwt} = Accounts.Token.generate(user)

    conn
    |> put_token_cookies(jwt)
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
