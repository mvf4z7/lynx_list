# Since configuration is shared in umbrella projects, this file
# should only configure the :lynx_list application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

config :lynx_list,
  ecto_repos: [LynxList.Repo]

import_config "#{Mix.env()}.exs"
