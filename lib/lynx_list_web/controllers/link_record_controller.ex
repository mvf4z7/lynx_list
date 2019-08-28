defmodule LynxListWeb.LinkRecordController do
  use LynxListWeb, :controller

  alias LynxList.Links

  def show(conn, %{"id" => id}) do
    case Links.get_link_record(id) do
      {:ok, link_record} ->
        render(conn, "show.json", link_record: link_record)

      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> put_view(LynxListWeb.ErrorView)
        |> render("error.json")
    end
  end
end
