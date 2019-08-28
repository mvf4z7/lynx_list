defmodule LynxListWeb.ErrorViewTest do
  use LynxListWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.json" do
    assert render(LynxListWeb.ErrorView, "404.json", []) == %{
             code: "NotFound",
             message: "Not Found",
             status: 404
           }
  end

  test "renders 500.json" do
    assert render(LynxListWeb.ErrorView, "500.json", []) == %{
             code: "InternalServerError",
             message: "Internal Server Error",
             status: 500
           }
  end
end
