defmodule LynxListWeb.AuthView do
  use LynxListWeb, :view

  alias LynxListWeb.UserView
  alias LynxList.Accounts.User

  def render("create.json", %{user: %User{}} = data) do
    UserView.render("show.json", data)
  end
end
