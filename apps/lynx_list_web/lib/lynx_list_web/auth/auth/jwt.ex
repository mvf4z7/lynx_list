defmodule LynxListWeb.Auth.JWT do
  use Joken.Config

  # 3 minutes
  @expiration_time 60 * 3

  @impl true
  def token_config do
    default_claims(iss: "LynxList", default_exp: @expiration_time, skip: [:nbf, :jti, :aud])
  end
end
