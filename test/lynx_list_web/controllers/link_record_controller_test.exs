defmodule LynxListWeb.LinkRecordControllerTest do
  use LynxListWeb.ConnCase, async: true

  alias Ecto.UUID
  alias LynxList.Exceptions.EntityNotFound
  alias LynxList.{Fixtures, Links}
  alias LynxListWeb.LinkRecordView

  setup do
    user = Fixtures.user()
    link_record = Fixtures.link_record(user)
    {:ok, link_record: link_record, user: user}
  end

  describe "POST /api/link-records/" do
    @url "/api/link-records/"
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
        |> post(@url, post_body)
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
        |> post(@url, post_body)

      assert response.status == 409
    end

    test "should return a 400 when a user submits invalid data", %{user: user} do
      invalid_data = [
        Map.drop(@valid_attrs, ["url"]),
        Map.put(@valid_attrs, "private", "foo"),
        Map.put(@valid_attrs, "title", true)
      ]

      Enum.each(invalid_data, fn post_body ->
        response =
          user
          |> create_authed_conn()
          |> post(@url, post_body)
          |> json_response(400)

        assert response == render_json(LynxListWeb.ErrorView, "invalid_input_error.json")
      end)
    end
  end

  describe "GET /api/link-record/<id>" do
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
      random_UUID = UUID.generate()

      conn =
        build_conn()
        |> get("/api/link-records/#{random_UUID}")

      exception = EntityNotFound.exception(entity_module: Links.LinkRecord, id: random_UUID)

      assert json_response(conn, 404) ==
               render_json(LynxListWeb.ErrorView, "EntityNotFound.json", exception: exception)
    end
  end
end
