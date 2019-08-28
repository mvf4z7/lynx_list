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
    Map.take(user, @attributes)
  end

  # TODO define a view for rendering a user reference. This would be a
  # JSON view for minimally displaying a user when they are referenced
  # from another entitie's JSON view (e.g. a LinkRecord has a user reference)
end
