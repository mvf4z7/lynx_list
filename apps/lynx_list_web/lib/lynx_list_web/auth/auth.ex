defmodule LynxListWeb.Auth do
  alias LynxListWeb.Auth.JWT
  alias LynxList.Accounts.User

  def generate_jwt_for_user(%User{} = user) do
    additionalClaims = %{
      data: %{
        user: %{
          id: user.id,
          email: user.email,
          name: user.name,
          username: user.username
        }
      }
    }

    {:ok, token, claims} = JWT.generate_and_sign(additionalClaims)
    token
  end
end
