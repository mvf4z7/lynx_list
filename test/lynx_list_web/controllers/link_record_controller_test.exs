defmodule LynxListWeb.LinkRecordControllerTest do
  use LynxListWeb.ConnCase, async: true

  alias Ecto.UUID
  alias LynxList.Fixtures

  setup do
    user = Fixtures.user()
    link_record = Fixtures.link_record(user)
    {:ok, link_record: link_record, user: user}
  end

  # test "GET /api/link-record/<id> should return LinkRecord with the provided id", %{
  #   link_record: link_record
  # } do
  #   conn =
  #     build_conn()
  #     |> get("/api/link-records/#{link_record.id}")

  #   IO.inspect(conn)
  # end

  test "GET /api/link-record<id> should return a 404 when a LinkRecord with the provided id does not exist" do
    conn =
      build_conn()
      |> get("/api/link-records/#{UUID.generate()}")

    assert json_response(conn, 404) ==
             render_json(LynxListWeb.ErrorView, "404.json")
  end
end
