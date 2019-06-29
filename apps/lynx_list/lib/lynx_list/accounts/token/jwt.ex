defmodule LynxList.Accounts.Token.JWT do
  use Joken.Config

  # 5 minutes
  @expiration_time 60 * 5

  @impl true
  def token_config do
    default_claims(iss: "LynxList", default_exp: @expiration_time, skip: [:nbf, :jti, :aud])
  end
end
