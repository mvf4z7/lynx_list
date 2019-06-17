defmodule LynxListWeb.Auth.Plugs do
  import Plug.Conn
  alias LynxListWeb.Auth

  @payload_key "token_payload"
  @header_signature_key "token_header_signature"
  @host Application.get_env(:lynx_list_web, LynxListWeb.Endpoint)
        |> Keyword.fetch!(:url)
        |> Keyword.fetch!(:host)

  def attempt_authentication(conn, options \\ []) do
    with {:ok, token} <- parse_jwt_from_cookies(conn),
         {{:ok, claims}, token} <- {Auth.verify_and_validate_jwt(token), token} do
      assign(conn, :token_claims, claims)
    else
      # User is not authenticated, let them pass through
      {:error, :failed_to_parse_jwt} ->
        conn

      {{:error, :expired_token}, token} ->
        IO.inspect("EXPIRED TOKEN")

        with {:ok, token} <- Auth.refresh_jwt(token) do
          put_jwt_cookies(conn, jwt: token)
        else
          # TODO: Send 500 error
          error ->
            conn
        end

      # TODO: Send an appropraite 400 error
      {{:error, :signature_error}, token} ->
        nil

      # TODO: properly handle this scenario
      unknown_error ->
        IO.inspect(unknown_error)
        nil
    end
  end

  def require_authentication(conn, options \\ []) do
  end

  def put_user(conn, _options) do
    # Use this when full user struct should be fetched from db
  end

  def put_jwt_cookies(conn, jwt: jwt) do
    [header, payload, signature] = String.split(jwt, ".")
    header_and_signature = "#{header}.#{signature}"

    conn
    |> put_resp_cookie(@payload_key, payload, domain: ".#{@host}", http_only: false)
    |> put_resp_cookie(@header_signature_key, header_and_signature,
      domain: ".#{@host}",
      http_only: true
    )
  end

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
end
