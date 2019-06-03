defmodule LynxList.Accounts do
  alias LynxList.Repo
  alias LynxList.Accounts.User

  def register_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changegset(attrs)
    |> Repo.insert()
  end
end
