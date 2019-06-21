defmodule LynxListWeb.Auth do
  alias LynxListWeb.Auth.JWT
  alias LynxList.Accounts
  alias LynxList.Accounts.User
  alias Plug.Conn

  def generate_jwt(%User{} = user) do
    additionalClaims = %{
      "data" => %{
        "user" => %{
          "id" => user.id,
          "email" => user.email,
          "name" => user.name,
          "username" => user.username
        }
      }
    }

    case JWT.generate_and_sign(additionalClaims) do
      {:ok, token, _claims} -> {:ok, token}
      error -> error
    end
  end

  def verify_jwt(token) when is_binary(token) do
    JWT.verify(token)
  end

  def verify_and_validate_jwt(token) when is_binary(token) do
    case JWT.verify_and_validate(token) do
      {:error, [message: "Invalid token", claim: "exp", claim_val: _]} -> {:error, :expired_token}
      result -> result
    end
  end

  def refresh_jwt(token) when is_binary(token) do
    with {:ok, claims} <- verify_jwt(token),
         {:ok, user_claims} <- get_user_claims(claims),
         {:get_user, user} <- {:get_user, Accounts.get_user(user_claims["id"])} do
      # TODO: Should check that the user is active first before generating
      generate_jwt(user)
    else
      {:get_user, nil} -> {:error, :user_does_not_exist}
      error -> error
    end
  end

  def get_user_claims(%Conn{} = _conn) do
  end

  def get_user_claims(claims) when is_map(claims) do
    case get_in(claims, ["data", "user"]) do
      nil -> {:error, :invalid_claims_format}
      value -> {:ok, value}
    end
  end

  def get_user(_conn) do
  end

  @spec is_authenticated?(Plug.Conn.t()) :: boolean()
  defdelegate is_authenticated?(conn), to: LynxListWeb.Auth.Plugs
end
