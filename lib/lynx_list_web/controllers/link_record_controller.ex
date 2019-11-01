defmodule LynxListWeb.LinkRecordController do
  use LynxListWeb, :controller

  alias LynxList.Exceptions.EntityNotFound
  alias LynxList.Links
  alias LynxList.Links.{LinkRecord, Policies}

  @require_auth [:create]

  plug :require_authentication, [load_user: true] when action in @require_auth
  plug :attempt_authentication, [load_user: true] when action not in @require_auth

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
    claims = get_user_claims(conn) || %{}
    user_id = Map.get(claims, "id")

    with {:ok, link_record} <- Links.get_link_record(id),
         {:can_view, true} <- {:can_view, Policies.can_view?(user_id, link_record)} do
      render(conn, "show.json", link_record: link_record)
    else
      {:error, %EntityNotFound{} = exception} ->
        conn
        |> put_status(404)
        |> put_view(LynxListWeb.ErrorView)
        |> render("EntityNotFound.json", exception: exception)

      {:can_view, false} ->
        conn
        |> put_status(404)
        |> put_view(LynxListWeb.ErrorView)
        |> render("EntityNotFound.json",
          exception: EntityNotFound.exception(entity_module: LinkRecord, id: id)
        )
    end
  end
end
