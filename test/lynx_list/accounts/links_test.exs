defmodule LynxList.LinksTest do
  use LynxList.DataCase, async: true

  alias LynxList.Fixtures
  alias LynxList.Links
  alias LynxList.Links.{Link, LinkRecord}
  alias LynxList.Repo

  describe "create_link/1" do
    @valid_attrs %{
      "title" => "A search engine",
      "url" => "htts://google.com"
    }

    test "should create a %Link{} that can be fetched from the database when passed valid attributes" do
      {:ok, link} = Links.create_link("https://google.com")

      assert %Link{} = link
      assert link.title == "https://google.com"
      assert link.url == "https://google.com"
      assert ^link = Repo.get(Link, link.id)
    end

    # test "should return an error tuple if a %Link{} with the given URL already exists" do
    #   link = Fixtures.link()
    #   attrs = Map.merge(@valid_attrs, %{"url" => link.url})

    #   assert {:error, _reason} = Links.create_link(attrs)

    #   {:error, :url_exists} = Links.create_link(attrs)
    # end
  end

  describe "get_link_by_url/1" do
  end

  describe "create_link_record/2" do
    @valid_attrs %{
      "description" => "A description",
      "private" => false,
      "title" => "A title",
      "url" => "https://google.com"
    }

    setup do
      user = Fixtures.user()
      {:ok, user: user}
    end

    test "should create a link record associated with the provided user", %{user: user} do
      assert {:ok, %LinkRecord{} = link_record} = Links.create_link_record(user, @valid_attrs)
      assert link_record.description == @valid_attrs["description"]
      assert link_record.private == false
      assert link_record.title == @valid_attrs["title"]
      assert link_record.link.url == @valid_attrs["url"]
      assert link_record.user == user
    end

    test "should default the description to an empty string", %{user: user} do
      attrs = Map.drop(@valid_attrs, ["description"])

      assert {:ok, link_record} = Links.create_link_record(user, attrs)
      assert link_record.description == ""
    end

    test "should default the title to an empty string", %{user: user} do
      attrs = Map.drop(@valid_attrs, ["title"])

      assert {:ok, link_record} = Links.create_link_record(user, attrs)
      assert link_record.title == ""
    end

    test "should default private to false", %{user: user} do
      attrs = Map.drop(@valid_attrs, ["private"])

      assert {:ok, link_record} = Links.create_link_record(user, attrs)
      assert link_record.private == false
    end

    test "should return a validation error if a url is not provided", %{user: user} do
      attrs = Map.drop(@valid_attrs, ["url"])

      assert {:error, :validation_error} = Links.create_link_record(user, attrs)
    end
  end
end
