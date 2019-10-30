defmodule LynxList.ChangesetHelpersTest do
  use LynxList.DataCase, async: true

  alias Ecto.Changeset
  alias LynxList.Accounts
  alias LynxList.ChangesetHelpers
  alias LynxList.Fixtures
  alias LynxList.Repo
  alias LynxList.ChangesetHelpersTest.Dummy

  defmodule Dummy do
    use Ecto.Schema

    embedded_schema do
      field :foo, :string
      field :bar, :integer
    end
  end

  describe "get_errors_map" do
    test "should return an empty map if the changeset is valid" do
      changeset = Changeset.change(%Dummy{})

      assert changeset.valid?
      assert ChangesetHelpers.get_errors_map(changeset) == %{}
    end

    test "should aggregate multiple errors for the same field in a list" do
      changeset =
        %Dummy{}
        |> Changeset.change(%{})
        |> Changeset.add_error(:foo, "Error message one")
        |> Changeset.add_error(:foo, "Error message two")

      result = ChangesetHelpers.get_errors_map(changeset)
      foo_errors = result.foo.errors

      assert length(foo_errors) == 2
      assert Enum.member?(foo_errors, "Error message one")
      assert Enum.member?(foo_errors, "Error message two")
    end

    test "should map variables in error messages" do
      changeset =
        %Dummy{}
        |> Changeset.change(%{})
        |> Changeset.add_error(:foo, "An %{adjective} error message", adjective: "exceptional")

      result = ChangesetHelpers.get_errors_map(changeset)

      assert %{
        foo: %{
          errors: ["An exceptional error message"]
        }
      }
    end

    test "should set the errored fields input value, using nil if a change was not provided" do
      changeset =
        %Dummy{}
        |> Changeset.change(%{bar: 1})
        |> Changeset.add_error(:foo, "foo error")
        |> Changeset.add_error(:bar, "bar error")

      result = ChangesetHelpers.get_errors_map(changeset)

      assert %{
               foo: %{value: nil},
               bar: %{value: 1}
             } = result
    end
  end

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
