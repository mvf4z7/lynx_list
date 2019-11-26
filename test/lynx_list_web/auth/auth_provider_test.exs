defmodule LynxListWeb.Auth.AuthProviderTest do
  use ExUnit.Case, async: true

  alias LynxListWeb.Auth.AuthProvider
  alias Ueberauth.Auth

  test "new/1 should return an %AuthProvider{}" do
    ueberauth = new_ueberauth(:github, 1234)
    auth_provider = AuthProvider.new(ueberauth)
    assert %AuthProvider{} = auth_provider
  end

  test "tokenize/1 should be the inverse of parseToken/1" do
    ueberauth = new_ueberauth(:github, 1234)
    auth_provider = AuthProvider.new(ueberauth)
    token = AuthProvider.tokenize(auth_provider)

    assert {:ok, result} = AuthProvider.verify_token(token)
    assert result == auth_provider
  end

  test "verify_token/1 should return an error if provided an invalid token" do
    assert {:error, :invalid} = AuthProvider.verify_token("invalid")
  end

  test "verify_token/1 should return an error if provided an expired token" do
  end

  defp new_ueberauth(provider, user_id) do
    %Auth{provider: provider, uid: user_id}
  end
end
