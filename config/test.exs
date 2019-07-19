use Mix.Config

# Configure your database
config :lynx_list, LynxList.Repo,
  username: "postgres",
  password: "postgres",
  database: "lynx_list_test",
  hostname: "localhost",
  port: 5434,
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :lynx_list, LynxListWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
