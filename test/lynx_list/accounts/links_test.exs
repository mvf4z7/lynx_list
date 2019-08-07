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
      {:ok, link} = Links.create_link(@valid_attrs)

      assert %Link{} = link
      assert link.title == @valid_attrs["title"]
      assert link.url == @valid_attrs["url"]
      assert ^link = Repo.get(Link, link.id)
    end

    @tag :only
    test "should return an error tuple if a %Link{} with the given URL already exists" do
      link = Fixtures.link()
      attrs = Map.merge(@valid_attrs, %{"url" => link.url})

      assert {:error, _reason} = Links.create_link(attrs)

      {:error, :url_exists} = Links.create_link(attrs)
    end
  end
end
