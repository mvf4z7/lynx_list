# Since configuration is shared in umbrella projects, this file
# should only configure the :lynx_list application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

config :lynx_list,
  ecto_repos: [LynxList.Repo]

config :lynx_list, LynxList.Repo, migration_primary_key: [name: :id, type: :binary_id]

import_config "#{Mix.env()}.exs"
