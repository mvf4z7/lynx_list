defmodule LynxList.Content.Link do
  use LynxList.Schema

  import Ecto.Changeset

  alias LynxList.Accounts

  @required_fields [:url]
  @cast_fields Enum.concat(@required_fields, [:description, :private, :title])

  schema "links" do
    field :description, :string
    field :private, :boolean, default: false
    field :title, :string
    field :url, :string

    belongs_to :owner, Accounts.User, foreign_key: :user_id

    timestamps()
  end

  def changeset(link \\ %__MODULE__{}, params) do
    # TODO: Validate length of text inputs
    link
    |> cast(params, @cast_fields)
    |> validate_required(@required_fields)
  end
end
