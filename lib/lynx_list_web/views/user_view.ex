defmodule LynxListWeb.UserView do
  use LynxListWeb, :view

  alias LynxList.Accounts.User

  def render("show.json", %{user: %User{} = user}) do
    %{
      createdAt: user.inserted_at,
      email: user.email,
      id: user.id,
      updatedAt: user.updated_at,
      username: user.username
    }
  end

  # TODO define a view for rendering a user reference. This would be a
  # JSON view for minimally displaying a user when they are referenced
  # from another entitie's JSON view (e.g. a LinkRecord has a user reference)
end
