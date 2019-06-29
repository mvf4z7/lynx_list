defmodule LynxList.Accounts.User do
  use LynxList.Schema

  import Ecto.Changeset
  alias LynxList.Accounts.Credentials

  @required_fields [:email, :enabled, :username]
  @cast_fields Enum.concat(@required_fields, [:name])

  schema "users" do
    field :email, :string
    field :enabled, :boolean
    field :name, :string
    field :username, :string

    has_one :credentials, Credentials

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
    |> validate_length(:username, min: 1, max: 20)
    |> unique_constraint(:email)
    |> unique_constraint(:username)
  end

  def registration_changegset(user, attrs) do
    user
    |> changeset(attrs)
    |> cast_assoc(:credentials, with: &Credentials.changeset/2, required: true)
  end
end
