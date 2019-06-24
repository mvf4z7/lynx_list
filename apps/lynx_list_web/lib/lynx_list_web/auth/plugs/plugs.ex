defmodule LynxListWeb.Auth.Plugs do
  import Plug.Conn
  alias LynxListWeb.Auth

  @host Application.get_env(:lynx_list_web, LynxListWeb.Endpoint)
        |> Keyword.fetch!(:url)
        |> Keyword.fetch!(:host)

  @payload_key "token_payload"
  @payload_options [domain: ".#{@host}", http_only: false]

  @header_signature_key "token_header_signature"
  @header_signature_options [domain: ".#{@host}", http_only: true]

  @claims_key :token_claims

  @spec attempt_authentication(Plug.Conn.t(), Plug.opts()) :: Plug.Conn.t()
  def attempt_authentication(conn, _options \\ []) do
    with {:ok, token} <- parse_jwt_from_cookies(conn),
         {{:ok, claims}, _token} <- {Auth.verify_and_validate_jwt(token), token} do
      put_claims(conn, claims)
    else
      {{:error, :expired_token}, token} ->
        case Auth.refresh_jwt(token) do
          {:ok, token} -> put_jwt_cookies(conn, jwt: token)
          _error -> delete_jwt_cookies(conn)
        end

      _error ->
        delete_jwt_cookies(conn)
    end
  end

  @spec require_authentication(Plug.Conn.t(), Plug.opts()) :: Plug.Conn.t()
  def require_authentication(conn, _options \\ []) do
    with new_conn <- attempt_authentication(conn),
         {true, new_conn} <- {is_authenticated?(new_conn), new_conn} do
      new_conn
    else
      {false, new_conn} ->
        new_conn
        |> put_status(401)
        |> Phoenix.Controller.render(LynxListWeb.ErrorView, "error.json")
        |> halt

      _unknown_error ->
        conn
        |> put_status(500)
        |> Phoenix.Controller.render(LynxListWeb.ErrorView, "error.json")
    end
  end

  @spec get_claims(Plug.Conn.t()) :: map() | nil
  def get_claims(conn), do: conn.assigns[@claims_key]

  @spec is_authenticated?(Plug.Conn.t()) :: boolean()
  def is_authenticated?(conn), do: Map.has_key?(conn.assigns, @claims_key)

  @spec put_jwt_cookies(Plug.Conn.t(), Plug.opts()) :: Plug.Conn.t()
  def put_jwt_cookies(conn, jwt: jwt) do
    [header, payload, signature] = String.split(jwt, ".")
    header_and_signature = "#{header}.#{signature}"

    conn
    |> put_resp_cookie(@payload_key, payload, @payload_options)
    |> put_resp_cookie(@header_signature_key, header_and_signature, @header_signature_options)
  end

  @spec delete_jwt_cookies(Plug.Conn.t(), Plug.opts()) :: Plug.Conn.t()
  def delete_jwt_cookies(conn, _options \\ []) do
    conn
    |> delete_resp_cookie(@payload_key, @payload_options)
    |> delete_resp_cookie(@header_signature_key, @header_signature_options)
  end

  @spec parse_jwt_from_cookies(Plug.Conn.t()) ::
          {:ok, String.t()} | {:error, :failed_to_parse_jwt}
  defp parse_jwt_from_cookies(conn) do
    conn = fetch_cookies(conn)
    cookies = conn.req_cookies

    with {:ok, header_and_signature} <- Map.fetch(cookies, @header_signature_key),
         [header, signature] <- String.split(header_and_signature, "."),
         {:ok, payload} <- Map.fetch(cookies, @payload_key) do
      {:ok, "#{header}.#{payload}.#{signature}"}
    else
      _ -> {:error, :failed_to_parse_jwt}
    end
  end

  @spec put_claims(Plug.Conn.t(), map()) :: Plug.Conn.t()
  defp put_claims(conn, claims) do
    assign(conn, @claims_key, claims)
  end
end
