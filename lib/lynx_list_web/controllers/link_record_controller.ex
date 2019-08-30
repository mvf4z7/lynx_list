defmodule LynxListWeb.LinkRecordController do
  use LynxListWeb, :controller

  alias LynxList.Links

  plug :attempt_authentication, load_user: true

  def create(conn, params) do
    user = get_user(conn)

    case Links.create_link_record(user, params) do
      {:ok, link_record} ->
        render(conn, "show.json", link_record: link_record)

      {:error, :url_exists} ->
        conn
        |> put_status(409)
        |> put_view(LynxListWeb.ErrorView)
        # TODO: Create a UniqueConstraintException
        |> render("error.json",
          code: :LinkRecordAlreadyExists,
          message:
            "A link record with the URL \"#{params["url"]}\" already exists for the current user"
        )

      {:error, :validation_error} ->
        conn
        |> put_status(400)
        |> put_view(LynxListWeb.ErrorView)
        |> render("invalid_input_error.json")
    end
  end

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
