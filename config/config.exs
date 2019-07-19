# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :lynx_list,
  ecto_repos: [LynxList.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :lynx_list, LynxListWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Ixm/7tnRU1MeossJWJohpckQUMp4kmmSPIdcCmLwdl/8Jro8PdUVI1SJJOTo/b0D",
  render_errors: [view: LynxListWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: LynxList.PubSub, adapter: Phoenix.PubSub.PG2]

config :lynx_list, LynxList.Repo, migration_primary_key: [name: :id, type: :binary_id]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ueberauth, Ueberauth,
  providers: [
    github:
      {Ueberauth.Strategy.Github,
       [default_scope: "user:email", callback_path: "/auth/github/callback"]},
    identity:
      {Ueberauth.Strategy.Identity,
       [
         callback_methods: ["POST"],
         uid_field: :username,
         callback_path: "/auth/identity/callback"
       ]}
  ]

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: "e59916e09864a28dc11c",
  client_secret: "437ca89b506b187ab91f9569ef79e005d3a8a550"

config :oauth2,
  serializers: %{
    "application/json" => Jason
  }

config :joken, default_signer: "JWT_SECRET"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
