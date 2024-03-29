use Mix.Config

# TODO: Scope this to the proper module
config :lynx_list,
  lynx_list_client_url: "http://localhost.com:3000"

# Configure your database
config :lynx_list, LynxList.Repo,
  username: "postgres",
  password: "postgres",
  database: "lynx_list_dev",
  hostname: "localhost",
  port: 5433,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with webpack to recompile .js and .css sources.
config :lynx_list, LynxListWeb.Endpoint,
  http: [port: 8800],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  secret_key_base: "Ixm/7tnRU1MeossJWJohpckQUMp4kmmSPIdcCmLwdl/8Jro8PdUVI1SJJOTo/b0D",
  watchers: []

config :cors_plug,
  origin: ["http://localhost.com:3000"]

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# Mix task:
#
#     mix phx.gen.cert
#
# Note that this task requires Erlang/OTP 20 or later.
# Run `mix help phx.gen.cert` for more information.
#
# The `http:` config above can be replaced with:
#
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime
