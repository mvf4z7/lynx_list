defmodule LynxList.LinksTest do
  use LynxList.DataCase, async: true

  alias LynxList.Fixtures
  alias LynxList.Links
  alias LynxList.Links.Link
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

  describe "create_link_record/2" do
    @tag :only
    test "should create a link record associated with the provided user" do
      user = Fixtures.user()
      attrs = %{"url" => "https://google.com"}
      link_record = Links.create_link_record(user, attrs)
      IO.inspect(link_record)
    end
  end
end
