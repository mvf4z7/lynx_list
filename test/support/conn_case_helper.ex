defmodule LynxListWeb.ConnCaseHelper do
  @spec render_json(atom, binary, keyword) :: map
  def render_json(view, template, assigns \\ []) do
    view.render(template, assigns) |> format_json
  end

  @spec format_json(map) :: map
  defp format_json(data) do
    data |> Jason.encode!() |> Jason.decode!()
  end
end
