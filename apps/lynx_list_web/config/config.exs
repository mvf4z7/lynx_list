# Since configuration is shared in umbrella projects, this file
# should only configure the :lynx_list_web application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

# General application configuration
config :lynx_list_web,
  ecto_repos: [LynxList.Repo],
  generators: [context_app: :lynx_list]

# Configures the endpoint
config :lynx_list_web, LynxListWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ZexdLaB77jmvaNnrqpguwzkwRyYQRsa8pixLOnma0WoX4Xn2BB74hlTIY8alSzGR",
  render_errors: [view: LynxListWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: LynxListWeb.PubSub, adapter: Phoenix.PubSub.PG2]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
