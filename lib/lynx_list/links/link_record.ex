defmodule LynxList.Links.LinkRecord do
  use LynxList.Schema

  import Ecto.Changeset

  alias Ecto.Changeset
  alias LynxList.Accounts
  alias LynxList.Links

  @required_fields [:private]
  @cast_fields [:description, :private, :title]
  @description_max_length 1000
  @title_max_length 255

  schema "link_records" do
    field :description, :string, default: ""
    field :private, :boolean, default: false
    field :title, :string, default: ""

    belongs_to :link, Links.Link
    belongs_to :user, Accounts.User

    timestamps()
  end

  def changeset(link_record \\ %__MODULE__{}, attrs) do
    link_record
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
    |> validate_length(:description, max: @description_max_length)
    |> validate_length(:title, max: @title_max_length)
    |> foreign_key_constraint(:link_id)
    |> foreign_key_constraint(:user_id)
  end

  def create_changeset(link_record \\ %__MODULE__{}, %{"link" => link, "user" => user} = attrs) do
    link_record
    |> changeset(attrs)
    |> put_assoc(:link, link)
    |> put_assoc(:user, user)
  end
end
