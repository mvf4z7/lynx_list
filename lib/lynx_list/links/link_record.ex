defmodule LynxList.Links.LinkRecord do
  use LynxList.Schema

  import Ecto.Changeset

  alias LynxList.Accounts
  alias LynxList.Links

  @required_fields [:description, :link, :private, :title, :user]
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

  def changeset(link \\ %__MODULE__{}, params) do
    # TODO: Validate length of text inputs
    link
    |> cast(params, @cast_fields)
    |> validate_required(@required_fields)
    |> validate_length(:description, max: @description_max_length)
    |> validate_length(:title, max: @title_max_length)
  end
end
