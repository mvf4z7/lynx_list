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

  describe "POST /api/link-record/" do
    @valid_attrs %{
      "description" => "Some description",
      "private" => false,
      "title" => "Some title",
      "url" => "http://google.com"
    }

    test "should return a 200 and a LinkRecord response body", %{user: user} do
      post_body = @valid_attrs

      json_response =
        user
        |> create_authed_conn()
        |> post("/api/link-records/", post_body)
        |> json_response(200)

      assert Map.keys(json_response) |> Enum.count() == 1
      assert %{"linkRecord" => link_record} = json_response

      {deterministic_fields, id_fields} = Map.split(link_record, Map.keys(post_body))
      assert deterministic_fields == post_body
      assert {:ok, _id} = UUID.cast(id_fields["id"])
      assert {:ok, _id} = UUID.cast(id_fields["parentLinkId"])
    end

    test "should return a 409 when a user tries to create LinkRecord with a repeated URL", %{
      link_record: link_record,
      user: user
    } do
      post_body = Map.put(@valid_attrs, "url", link_record.link.url)

      response =
        user
        |> create_authed_conn()
        |> post("/api/link-records/", post_body)

      assert response.status == 409
    end
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
