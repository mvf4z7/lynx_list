defmodule LynxList.TokenTest do
  use LynxList.DataCase, async: true

  alias LynxList.Accounts
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

    test "it should return a :signature_error if the token has been tampered with" do
      {:ok, token} =
        Fixtures.user()
        |> Token.generate()

      tampered = tamper_token(token)

      assert Token.verify_and_validate(tampered) == {:error, :signature_error}
    end
  end

  describe "get_user_claims" do
    test "it should return properly formatted user claims if passed a proper claims map" do
      user = Fixtures.user()
      {:ok, token} = Token.generate(user)
      {:ok, claims} = Token.verify_and_validate(token)

      {:ok, user_claims} = Token.get_user_claims(claims)

      assert ^user_claims = %{
               "id" => user.id,
               "email" => user.email,
               "name" => user.name,
               "username" => user.username
             }
    end

    test "it should return an error when the provided claims that are in an invalid format" do
      invalid_claims = %{"user" => %{id: "foobar"}}

      assert {:error, :invalid_claims} = Token.get_user_claims(invalid_claims)
    end
  end

  describe "refresh_jwt" do
    test "it should return a new token with a greater experiation time" do
      {claims, new_claims} =
        with user <- Fixtures.user(),
             {:ok, token} <- Token.generate(user),
             {:ok, claims} <- Token.verify_and_validate(token),

             #  Sleep to ensure that the token is generated at least 1 second
             # after the original token, since the expiration time is in seconds
             _ <- :timer.sleep(1000),
             {:ok, new_token} <- Token.refresh(token),
             {:ok, new_claims} <- Token.verify_and_validate(new_token) do
          {claims, new_claims}
        end

      exp = Map.fetch!(claims, "exp")
      new_exp = Map.fetch!(new_claims, "exp")

      temporal_claim_keys = ["exp", "iat"]
      non_temporal_claims = Map.drop(claims, temporal_claim_keys)
      non_temporal_new_claims = Map.drop(new_claims, temporal_claim_keys)

      assert new_exp > exp
      assert ^non_temporal_new_claims = non_temporal_claims
    end

    test "it should return an error if the user is disabled" do
      user = Fixtures.user()
      {:ok, token} = Token.generate(user)

      _ = Accounts.update_user(user, %{enabled: false})

      assert {:error, :user_is_disabled} = Token.refresh(token)
    end

    test "it should return an error if the user no longer exists" do
      user = Fixtures.user()
      {:ok, token} = Token.generate(user)

      Accounts.delete_user(user)

      assert {:error, :user_does_not_exist} = Token.refresh(token)
    end
  end
end
