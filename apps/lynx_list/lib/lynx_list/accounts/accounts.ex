defmodule LynxList.Accounts do
  import Ecto.Query, only: [from: 2]
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

  def get_user_by_github_id!(id) do
    query =
      from u in User,
        join: c in Credentials,
        on: c.user_id == u.id,
        where: c.github_id == ^id

    Repo.one!(query)
  end
end
