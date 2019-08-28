defmodule LynxListWeb.LinkRecordControllerTest do
  use LynxListWeb.ConnCase, async: true

  alias Ecto.UUID
  alias LynxList.Fixtures
  alias LynxListWeb.LinkRecordView

  setup do
    user = Fixtures.user()
    link_record = Fixtures.link_record(user)
    {:ok, link_record: link_record, user: user}
  end

  test "POST /api/link-record/ should return a 200 and a LinkRecord response body", %{user: user} do
    conn =
      user
      |> create_authed_conn()

    body = %{
      "description" => "Some description",
      "private" => false,
      "title" => "Some title",
      "url" => "http://google.com"
    }

    json_response =
      conn
      |> post("/api/link-records/", body)
      |> json_response(200)

    assert Map.keys(json_response) |> Enum.count() == 1
    assert %{"linkRecord" => link_record} = json_response

    {deterministic_fields, id_fields} = Map.split(link_record, Map.keys(body))
    assert deterministic_fields == body
    assert {:ok, _id} = UUID.cast(id_fields["id"])
    assert {:ok, _id} = UUID.cast(id_fields["parentLinkId"])
  end

  test "GET /api/link-record/<id> should return LinkRecord with the provided id", %{
    link_record: link_record,
    user: user
  } do
    json_response =
      user
      |> create_authed_conn()
      |> get("/api/link-records/#{link_record.id}")
      |> json_response(200)

    assert json_response ==
             render_json(LinkRecordView, "show.json", link_record: link_record)
  end

  test "GET /api/link-record<id> should return a 404 when a LinkRecord with the provided id does not exist" do
    conn =
      build_conn()
      |> get("/api/link-records/#{UUID.generate()}")

    assert json_response(conn, 404) ==
             render_json(LynxListWeb.ErrorView, "404.json")
  end
end
