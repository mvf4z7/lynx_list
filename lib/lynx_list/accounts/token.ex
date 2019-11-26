defmodule LynxList.Accounts.Token do
  alias LynxList.Accounts
  alias LynxList.Accounts.Token.JWT
  alias LynxList.Accounts.User

  @type t :: binary
  @type claims :: %{optional(binary) => any}
  @type error_reason :: atom | keyword

  @spec generate(%User{}, map()) :: {:error, error_reason} | {:ok, t}
  def generate(user, additional_claims \\ %{})

  def generate(%User{enabled: true} = user, additional_claims) do
    user_claims = %{
      "data" => %{
        "user" => %{
          "id" => user.id,
          "email" => user.email,
          "name" => user.name,
          "username" => user.username
        }
      }
    }

    dynamic_claims = Map.merge(additional_claims, user_claims)

    case JWT.generate_and_sign(dynamic_claims) do
      {:ok, token, _claims} -> {:ok, token}
      {:error, reason} -> {:error, reason}
    end
  end

  def generate(%User{enabled: false}, _additional_claims) do
    {:error, :disabled_user}
  end

  @spec get_user_claims(claims) :: {:error, :invalid_claims} | {:ok, claims}
  def get_user_claims(claims) when is_map(claims) do
    case get_in(claims, ["data", "user"]) do
      nil -> {:error, :invalid_claims}
      value -> {:ok, value}
    end
  end

  @spec verify_and_validate(t) :: {:error, error_reason} | {:ok, claims}
  def verify_and_validate(token) when is_binary(token) do
    case JWT.verify_and_validate(token) do
      {:error, [message: "Invalid token", claim: "exp", claim_val: _]} -> {:error, :expired_token}
      {:error, _} -> {:error, :signature_error}
      {:ok, claims} -> {:ok, claims}
    end
  end

  @spec refresh(t) :: {:error, error_reason} | {:ok, t}
  def refresh(token) when is_binary(token) do
    with {:ok, claims} <- verify(token),
         {:ok, user_claims} <- get_user_claims(claims),
         {:get_user, user} when not is_nil(user) <-
           {:get_user, Accounts.get_user(user_claims["id"])},
         {:enabled, true} <- {:enabled, user.enabled} do
      generate(user)
    else
      {:get_user, nil} -> {:error, :user_does_not_exist}
      {:enabled, false} -> {:error, :user_is_disabled}
      error -> error
    end
  end

  @spec verify(t) :: {:error, error_reason} | {:ok, claims}
  defp verify(token) when is_binary(token) do
    JWT.verify(token)
  end
end
