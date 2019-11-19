defmodule LynxListWeb.AuthController do
  use LynxListWeb, :controller

  alias LynxList.Accounts
  plug Ueberauth

  @lynx_list_client_url Application.get_env(:lynx_list, :lynx_list_client_url)

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
    IO.inspect(params)
    redirect_path = Map.get(params, "state", "/receive")

    with {:ok, user} <- get_user_from_auth(auth),
         {:ok, jwt} <- Accounts.Token.generate(user),
         conn <- put_token_cookies(conn, jwt) do
      redirect(conn, external: "#{@lynx_list_client_url}#{redirect_path}")
    else
      :not_found ->
        user_details = get_user_details_from_callback(auth)

        redirect(conn,
          external: "#{@lynx_list_client_url}/register?#{URI.encode_query(user_details)}"
        )

      _error ->
        redirect(conn, external: "#{@lynx_list_client_url}/error")
    end

    conn
    |> do_callback(provider, auth)
    |> redirect(external: "#{@lynx_list_client_url}#{redirect_path}")
  end

  defp get_user_from_auth(%Ueberauth.Auth{provider: :github} = auth) do
    github_id = auth.uid
    Accounts.get_user_by_github_id(github_id)
  end

  defp get_user_details_from_callback(%Ueberauth.Auth{info: info}) do
    %{name: info.name, username: info.nickname, email: info.email}
  end

  defp do_callback(conn, "github", auth) do
    github_id = auth.uid

    case Accounts.get_user_by_github_id(github_id) do
      {:ok, user} ->
        {:ok, jwt} = Accounts.Token.generate(user)
        put_token_cookies(conn, jwt)

      :not_found ->
        conn
    end
  end

  def create_account(conn, params) do
    {:ok, user} = Accounts.register_user(params)
    render(conn, "create.json", user: user)
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
