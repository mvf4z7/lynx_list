defmodule LynxListWeb.UserView do
  use LynxListWeb, :view

  alias LynxList.Accounts.User

  @attributes [
    :email,
    :id,
    :inserted_at,
    :updated_at,
    :username
  ]

  def render("show.json", %{user: %User{} = user}) do
    map = Map.take(user, @attributes)
    IO.inspect(map)
    map
  end
end
