defmodule LynxList.TokenTest do
  use LynxList.DataCase

  alias LynxList.Accounts.Token
  alias LynxList.Accounts.Token.JWT
  alias LynxList.Accounts.User
  alias LynxList.Fixtures

  def assertClaims(claims, %User{} = user) do
    assert %{} = claims
    assert claims["iss"] == "LynxList"
    assert is_integer(claims["exp"]) == true

    user_claims = claims["data"]["user"]
    assert user_claims != nil

    assert ^user_claims = %{
             "id" => user.id,
             "email" => user.email,
             "name" => user.name,
             "username" => user.username
           }
  end

  def tamper_token(token) do
    [header, payload, footer] = String.split(token, ".")

    [header, String.reverse(payload), footer]
    |> Enum.join(".")
  end

  describe "generate" do
    test "it should generate a valid token with properly formatted claims when passed an enabled user" do
      user = Fixtures.user()
      {:ok, token} = Token.generate(user)

      claims = JWT.verify_and_validate!(token)
      assertClaims(claims, user)
    end

    test "it should return an error when passed a disabled user" do
      user = Fixtures.user(%{enabled: false})
      assert {:error, :disabled_user} = Token.generate(user)
    end
  end

  describe "verify_and_validate" do
    test "it should return valid claims if token is untampered" do
      user = Fixtures.user()
      {:ok, token} = Token.generate(user)

      {:ok, claims} = Token.verify_and_validate(token)
      assertClaims(claims, user)
    end

    test "it should return a :signature_error if the token is tampered with" do
      {:ok, token} =
        Fixtures.user()
        |> Token.generate()

      tampered = tamper_token(token)

      assert Token.verify_and_validate(tampered) == {:error, :signature_error}
    end
  end
end
