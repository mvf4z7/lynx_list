defmodule LyxnList.AccountsTest do
  use LynxList.DataCase, async: true

  alias LynxList.Accounts
  alias LynxList.Accounts.User
  alias LynxList.Fixtures

  test "get_user returns the user with the given id" do
    user = Fixtures.user()
    assert Accounts.get_user(user.id) == user
  end

  test "get_user return nil if a user with the given id does not exist" do
    assert nil == Accounts.get_user(Ecto.UUID.generate())
  end

  test "get_user! return the user with the given id" do
    user = Fixtures.user()
    assert Accounts.get_user(user.id) == user
  end

  test "get_user! throws Ecto.NoResultsError if a usre with the given id does not exist" do
    assert %Ecto.NoResultsError{} = catch_error(Accounts.get_user!(Ecto.UUID.generate()))
  end

  test "register_user/1 with valid data creates a user" do
    valid_attrs = %{
      email: "foo@example.com",
      enabled: true,
      name: "Some Name",
      username: "foo",
      credentials: %{
        password: "supersecret"
      }
    }

    assert {:ok, %User{} = user} = Accounts.register_user(valid_attrs)
    assert user.email == "foo@example.com"
    assert user.enabled == true
    assert user.name == "Some Name"
    assert user.username == "foo"
    assert %Ecto.Association.NotLoaded{} = user.credentials
  end

  test "register_user/1 will enable a users account by default" do
    attrs =
      Fixtures.user_attrs()
      |> Map.drop([:enabled])

    assert {:ok, %User{} = user} = Accounts.register_user(attrs)
    assert user.enabled == true
  end

  test "get_user_by_github_id/1 with a valid id returns the corresponding user" do
    overrides = %{
      credentials: %{
        github_id: 33
      }
    }

    user = Fixtures.user(overrides)
    assert {:ok, user} == Accounts.get_user_by_github_id(33)
  end

  test "get_user_by_github_id/1 with an invalid id returns :not_found" do
    assert :not_found == Accounts.get_user_by_github_id(33)
  end
end
