defmodule LynxListWeb.AuthController do
  use LynxListWeb, :controller

  alias LynxList.Accounts
  alias LynxListWeb.Auth

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

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, params) do
    redirect_path = Map.get(params, "state", "/receive")

    with {:ok, user} <- get_user_by_provider(auth.provider, auth.uid),
         {:ok, jwt} <- Accounts.Token.generate(user),
         conn <- Auth.put_jwt_cookies(conn, jwt: jwt) do
      redirect(conn, external: "#{@lynx_list_client_url}#{redirect_path}")
    else
      :not_found ->
        user_details = get_user_details_from_callback(auth)

        conn
        |> Auth.put_provider_cookie(auth: auth)
        |> redirect(
          external: "#{@lynx_list_client_url}/register?#{URI.encode_query(user_details)}"
        )

      _error ->
        redirect(conn, external: "#{@lynx_list_client_url}/error")
    end
  end

  def callback(conn, _params) do
    conn
    |> put_status(401)
    |> put_view(LynxListWeb.ErrorView)
    |> render("error.json", message: "Invalid credentials")
  end

  def create_account(conn, params) do
    params =
      case Auth.parse_provider_cookie(conn) do
        nil ->
          params

        auth_provider ->
          Map.put(params, "credentials", %{"#{auth_provider.name}_id" => auth_provider.user_id})
      end

    IO.inspect(params)
    {:ok, user} = Accounts.register_user(params)
    render(conn, "create.json", user: user)
  end

  defp get_user_by_provider(:github, github_id) do
    Accounts.get_user_by_github_id(github_id)
  end

  defp get_user_details_from_callback(%Ueberauth.Auth{info: info}) do
    %{name: info.name, username: info.nickname, email: info.email}
  end
end
