defmodule LyxnList.AccountsTest do
  use LynxList.DataCase, async: true

  alias LynxList.Accounts
  alias LynxList.Accounts.User

  @valid_registration_attrs %{
    email: "someemail@foo.com",
    name: "some name",
    username: "someusername",
    credentials: %{
      password: "password"
    }
  }

  test "register_user/1 with valid data creates a user" do
    assert {:ok, %User{} = user} = Accounts.register_user(@valid_registration_attrs)

    IO.inspect(user)
    assert user.email == "someemail@foo.com"
    assert user.name == "some name"
    assert user.username == "someusername"
  end
end
