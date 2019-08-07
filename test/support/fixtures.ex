defmodule LynxList.Fixtures do
  alias LynxList.Accounts
  alias LynxList.Accounts.User
  alias LynxList.Links
  alias LynxList.Links.Link

  @spec user(map()) :: %User{}
  def user(attrs \\ %{}) do
    username = "user#{System.unique_integer([:positive])}"

    default_attrs = %{
      email: "#{username}@example.com",
      enabled: true,
      name: "Some Name",
      username: username,
      credentials: %{
        password: "supersecret"
      }
    }

    {:ok, user} =
      default_attrs
      |> Map.merge(attrs, fn k, v1, v2 ->
        case k do
          :credentials -> Map.merge(v1, v2)
          _ -> v2
        end
      end)
      |> Accounts.register_user()

    user
  end

  @spec link(map) :: %Link{}
  def link(attrs \\ %{}) do
    {:ok, link} =
      %{
        title: "Some title",
        url: "https://google.com"
      }
      |> Map.merge(attrs)
      |> Links.create_link()

    link
  end
end
