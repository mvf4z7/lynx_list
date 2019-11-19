defmodule LynxList.Accounts do
  import Ecto.Query, only: [from: 2]
  alias Ecto.Changeset

  alias LynxList.Repo
  alias LynxList.Accounts.{User, Credentials}

  def get_user(id) do
    Repo.get(User, id)
  end

  def get_user!(id) do
    Repo.get!(User, id)
  end

  def register_user(attrs \\ %{}) do
    {:ok, user} =
      %User{}
      |> User.registration_changegset(attrs)
      |> Repo.insert()

    case get_user(user.id) do
      %User{} = user -> {:ok, user}
      _ -> {:error, "failed to create user"}
    end
  end

  @spec get_user_by_github_id(integer()) :: {:ok, %User{}} | :not_found
  def get_user_by_github_id(id) do
    query =
      from u in User,
        join: c in Credentials,
        on: c.user_id == u.id,
        where: c.github_id == ^id

    case Repo.one(query) do
      nil -> :not_found
      user -> {:ok, user}
    end
  end

  @spec update_user(%User{}, map) :: {:error, Changeset.t()} | {:ok, %User{}}
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @spec delete_user(%User{}) :: {:error, Changeset.t()} | {:ok, %User{}}
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end
end
