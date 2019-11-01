defmodule LynxList.Fixtures do
  alias LynxList.Accounts
  alias LynxList.Accounts.User
  alias LynxList.Links
  alias LynxList.Links.{Link, LinkRecord}

  @spec user_attrs(map()) :: map()
  def user_attrs(attrs \\ %{}) do
    username = "user#{System.unique_integer([:positive])}"

    %{
      email: "#{username}@example.com",
      enabled: true,
      name: "Some Name",
      username: username,
      credentials: %{
        password: "supersecret"
      }
    }
    |> Map.merge(attrs, fn k, v1, v2 ->
      case k do
        :credentials -> Map.merge(v1, v2)
        _ -> v2
      end
    end)
  end

  @spec user(map()) :: %User{}
  def user(attrs \\ %{}) do
    {:ok, user} =
      user_attrs(attrs)
      |> Accounts.register_user()

    user
  end

  @spec link(binary) :: %Link{}
  def link(url \\ "https://google.com") do
    {:ok, link} = Links.create_link(url)
    link
  end

  @spec link_record(%User{}, map()) :: %LinkRecord{}
  def link_record(%User{} = user, overrides \\ %{}) do
    attrs =
      %{
        "description" => "Some description",
        "private" => false,
        "title" => "Some title",
        "url" => "http://random-url-#{System.unique_integer([:positive])}.com"
      }
      |> Map.merge(overrides)

    {:ok, link_record} = Links.create_link_record(user, attrs)
    link_record
  end
end
