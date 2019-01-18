defmodule LynxList.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      LynxList.Repo
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: LynxList.Supervisor)
  end
end
