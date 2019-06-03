defmodule LynxList.Accounts.Credentials do
  use LynxList.Schema

  import Ecto.Changeset
  alias LynxList.Accounts

  schema "credentials" do
    field :password_hash, :string
    field :password, :string, virtual: true
    field :github_id, :integer

    belongs_to :user, Accounts.User

    timestamps()
  end

  @doc false
  def changeset(credentials, attrs) do
    credentials
    |> cast(attrs, [:password, :github_id])
    |> validate_atleast_one_required([:password, :github_id])
    |> put_password_hash()
    |> foreign_key_constraint(:user_id)
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Comeonin.Pbkdf2.hashpwsalt(password))

      _ ->
        changeset
    end
  end

  defp validate_atleast_one_required(changeset, fields) when is_list(fields) do
    case Enum.any?(fields, &present?(changeset, &1)) do
      false ->
        add_error(
          changeset,
          hd(fields),
          "At least one of the following fields is required: #{IO.inspect(fields)}"
        )

      true ->
        changeset
    end
  end

  defp present?(changeset, field) do
    value = get_field(changeset, field)
    value != nil && value != ""
  end
end
