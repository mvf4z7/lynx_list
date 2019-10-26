defmodule LynxList.ChangesetHelpersTest do
  use LynxList.DataCase, async: true

  alias Ecto.Changeset
  alias LynxList.Accounts
  alias LynxList.ChangesetHelpers
  alias LynxList.Fixtures
  alias LynxList.Repo

  describe "has_unique_constraing?/1" do
    test "should return true when a unique constraint is violated" do
      user = Fixtures.user()

      {:error, changeset} =
        user
        |> Map.take([:username])
        |> Fixtures.user_attrs()
        |> Accounts.User.changeset()
        |> Repo.insert()

      assert ChangesetHelpers.has_unique_constraint?(changeset, :username) == true
    end

    test "should return false when passed a valid changeset" do
      changeset =
        Fixtures.user_attrs()
        |> Accounts.User.changeset()

      assert %Changeset{valid?: true} = changeset
      assert ChangesetHelpers.has_unique_constraint?(changeset, :username) == false
    end

    test "should return false when passed an invalid changeset that doesn't have a unique constraint violation" do
      invalid_changeset =
        %Accounts.User{}
        |> Changeset.cast(%{}, [])
        |> Changeset.validate_required([:username])

      assert %Changeset{valid?: false} = invalid_changeset
      assert ChangesetHelpers.has_unique_constraint?(invalid_changeset, :username) == false
    end
  end
end
