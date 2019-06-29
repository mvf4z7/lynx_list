defmodule LynxList.Accounts.Token do
  alias LynxList.Accounts.Token.JWT
  alias LynxList.Accounts.User

  @type claims :: %{optional(binary) => any}
  @type token_error_reason :: atom | keyword

  @spec generate(User.t()) :: {:error, token_error_reason} | {:ok, claims}
  def generate(%User{enabled: true} = user) do
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
      {:error, reason} -> {:error, reason}
    end
  end

  def generate(%User{enabled: false}) do
    {:error, :disabled_user}
  end

  # @spec verify(binary) :: {:error, token_error_reason} | {:ok, claims}
  # def verify(token) when is_binary(token) do
  #   JWT.verify(token)
  # end

  @spec verify_and_validate(binary) :: {:error, token_error_reason} | {:ok, claims}
  def verify_and_validate(token) when is_binary(token) do
    case JWT.verify_and_validate(token) do
      {:error, [message: "Invalid token", claim: "exp", claim_val: _]} -> {:error, :expired_token}
      {:error, _} -> {:error, :signature_error}
      {:ok, claims} -> {:ok, claims}
    end
  end
end
