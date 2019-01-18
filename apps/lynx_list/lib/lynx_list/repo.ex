defmodule LynxList.Repo do
  use Ecto.Repo,
    otp_app: :lynx_list,
    adapter: Ecto.Adapters.Postgres
end
