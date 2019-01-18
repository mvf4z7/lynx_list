# Since configuration is shared in umbrella projects, this file
# should only configure the :lynx_list application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

# Configure your database
config :lynx_list, LynxList.Repo,
  username: "postgres",
  password: "postgres",
  database: "lynx_list_dev",
  hostname: "localhost",
  pool_size: 10
