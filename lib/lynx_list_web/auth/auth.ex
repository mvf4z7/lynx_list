defmodule LynxListWeb.Auth do
  import Plug.Conn

  alias LynxList.Accounts
  alias LynxListWeb.Auth.AuthProvider

  @host Application.get_env(:lynx_list, LynxListWeb.Endpoint)
        |> Keyword.fetch!(:url)
        |> Keyword.fetch!(:host)
  @cookie_domain ".#{@host}"

  @payload_key "token_payload"
  @payload_options [domain: @cookie_domain, http_only: false]

  @header_signature_key "token_header_signature"
  @header_signature_options [domain: @cookie_domain, http_only: true]

  @claims_key :token_claims
  @user_key :user

  @auth_provider_key "auth_provider"
  @auth_provider_options [
    domain: @cookie_domain,
    http_only: true
  ]

  @spec put_jwt_cookies(Plug.Conn.t(), Plug.opts()) :: Plug.Conn.t()
  def put_jwt_cookies(conn, jwt: jwt) do
    [header, payload, signature] = String.split(jwt, ".")
    header_and_signature = "#{header}.#{signature}"

    conn
    |> put_resp_cookie(@payload_key, payload, @payload_options)
    |> put_resp_cookie(@header_signature_key, header_and_signature, @header_signature_options)
  end

  @spec attempt_authentication(Plug.Conn.t(), Plug.opts()) :: Plug.Conn.t()
  def attempt_authentication(conn, options \\ []) do
    load_user = Keyword.get(options, :load_user, false)

    with {:ok, token} <- parse_jwt_from_cookies(conn),
         {:ok, new_token, claims} <- refresh_verify_and_validate(token),
         new_conn <- put_jwt_cookies(conn, jwt: new_token),
         new_conn <- put_claims(new_conn, claims),
         user_claims <- get_user_claims(new_conn),
         user <- load_user && Accounts.get_user!(user_claims["id"]) do
      case load_user do
        true -> put_user(new_conn, user)
        false -> new_conn
      end
    else
      _error ->
        delete_jwt_cookies(conn)
    end
  end

  @spec require_authentication(Plug.Conn.t(), Plug.opts()) :: Plug.Conn.t()
  def require_authentication(conn, options \\ []) do
    with new_conn <- attempt_authentication(conn, options),
         {true, new_conn} <- {is_authenticated?(new_conn), new_conn} do
      new_conn
    else
      {false, new_conn} ->
        new_conn
        |> put_status(401)
        |> Phoenix.Controller.put_view(LynxListWeb.ErrorView)
        |> Phoenix.Controller.render("error.json")
        |> halt

      _unknown_error ->
        conn
        |> put_status(500)
        |> Phoenix.Controller.put_view(LynxListWeb.ErrorView)
        |> Phoenix.Controller.render("error.json")
    end
  end

  @spec is_authenticated?(Plug.Conn.t()) :: boolean()
  def is_authenticated?(conn), do: Map.has_key?(conn.assigns, @claims_key)

  @spec get_claims(Plug.Conn.t()) :: map() | nil
  def get_claims(conn), do: conn.assigns[@claims_key]

  @spec get_user_claims(Plug.Conn.t()) :: map() | nil
  def get_user_claims(%Plug.Conn{} = conn) do
    with {:claims, claims} when not is_nil(claims) <- {:claims, get_claims(conn)},
         {:ok, user_claims} <- Accounts.Token.get_user_claims(claims) do
      user_claims
    else
      _ ->
        nil
    end
  end

  @spec get_user(Plug.Conn.t()) :: %Accounts.User{} | nil
  def get_user(%Plug.Conn{} = conn), do: conn.assigns[@user_key]

  @spec put_provider_cookie(Plug.Conn.t(), auth: Ueberauth.Auth.t()) :: Plug.Conn.t()
  def put_provider_cookie(conn, auth: auth) do
    auth_provider = AuthProvider.new(auth)
    token = AuthProvider.tokenize(auth_provider)

    conn
    |> put_resp_cookie(@auth_provider_key, token, @auth_provider_options)
  end

  @spec parse_provider_cookie(Plug.Conn.t()) :: AuthProvider.t() | nil
  def parse_provider_cookie(conn) do
    conn = fetch_cookies(conn)
    IO.inspect(conn)

    with {:ok, token} <- Map.fetch(conn.cookies, @auth_provider_key),
         {:ok, auth_provider} <- AuthProvider.verify_token(token) do
      auth_provider
    else
      error ->
        IO.inspect(error)
        nil
    end
  end

  defp refresh_verify_and_validate(token) do
    case Accounts.Token.verify_and_validate(token) do
      {:ok, claims} ->
        {:ok, token, claims}

      {:error, :expired_token} ->
        {:ok, new_token} = Accounts.Token.refresh(token)
        {:ok, claims} = Accounts.Token.verify_and_validate(new_token)
        {:ok, new_token, claims}

      error ->
        error
    end
  end

  @spec delete_jwt_cookies(Plug.Conn.t(), Plug.opts()) :: Plug.Conn.t()
  defp delete_jwt_cookies(conn, _options \\ []) do
    conn
    |> delete_resp_cookie(@payload_key, @payload_options)
    |> delete_resp_cookie(@header_signature_key, @header_signature_options)
  end

  @spec parse_jwt_from_cookies(Plug.Conn.t()) ::
          {:ok, binary} | {:error, :failed_to_parse_jwt}
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

  @spec put_user(Plug.Conn.t(), %Accounts.User{}) :: Plug.Conn.t()
  defp put_user(conn, user) do
    assign(conn, @user_key, user)
  end
end
