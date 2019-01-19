# Since configuration is shared in umbrella projects, this file
# should only configure the :lynx_list application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

# Configure your database

config :lynx_list, LynxList.Repo,
  show_sensitive_data_on_connection_error: true,
  username: System.get_env("PG_USER"),
  password: System.get_env("PG_PASS"),
  database: System.get_env("PG_DB"),
  hostname: System.get_env("PG_HOST"),
  pool_size: 10
