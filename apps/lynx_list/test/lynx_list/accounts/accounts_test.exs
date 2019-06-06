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

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      @valid_registration_attrs
      |> Map.merge(attrs, fn k, v1, v2 ->
        case k do
          :credentials -> Map.merge(v1, v2)
          _ -> v2
        end
      end)
      |> Accounts.register_user()

    user
  end

  test "get_user returns the user with the given id" do
    user = user_fixture()
    assert Accounts.get_user(user.id) == user
  end

  test "get_user return nil if a user with the given id does not exist" do
    assert nil == Accounts.get_user(Ecto.UUID.generate())
  end

  test "get_user! return the user with the given id" do
    user = user_fixture()
    assert Accounts.get_user(user.id) == user
  end

  test "get_user! throws Ecto.NoResultsError if a usre with the given id does not exist" do
    assert %Ecto.NoResultsError{} = catch_error(Accounts.get_user!(Ecto.UUID.generate()))
  end

  test "register_user/1 with valid data creates a user" do
    assert {:ok, %User{} = user} = Accounts.register_user(@valid_registration_attrs)
    assert user.email == "someemail@foo.com"
    assert user.name == "some name"
    assert user.username == "someusername"
    assert %Ecto.Association.NotLoaded{} = user.credentials
  end

  test "get_user_by_github_id/1 with a valid id returns the corresponding user" do
    overrides = %{
      credentials: %{
        github_id: 33
      }
    }

    user = user_fixture(overrides)
    assert user == Accounts.get_user_by_github_id!(33)
  end
end
