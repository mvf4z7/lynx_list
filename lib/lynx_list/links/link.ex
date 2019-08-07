defmodule LynxList.Links.Link do
  use LynxList.Schema

  import Ecto.Changeset

  alias Ecto.Changeset

  @required_fields [:last_updated_meta, :title, :url]
  @cast_fields [:title, :url]

  schema "links" do
    field :last_updated_meta, :utc_datetime
    field :title, :string, default: ""
    field :url, :string

    timestamps()
  end

  @spec changeset(%__MODULE__{}, map) :: %Changeset{}
  def changeset(link \\ %__MODULE__{}, params) do
    link
    |> cast(params, @cast_fields)
    |> put_last_upated_meta()
    |> validate_required(@required_fields)
    |> unique_constraint(:url)
  end

  @spec put_last_upated_meta(%Changeset{}) :: %Changeset{}
  defp put_last_upated_meta(%Changeset{valid?: true} = changeset) do
    case get_change(changeset, :title) do
      nil ->
        changeset

      _ ->
        put_change(
          changeset,
          :last_updated_meta,
          DateTime.utc_now() |> DateTime.truncate(:second)
        )
    end
  end

  defp put_last_upated_meta(%Changeset{valid?: false} = changeset) do
    changeset
  end
end
