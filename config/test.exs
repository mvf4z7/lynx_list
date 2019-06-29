use Mix.Config

# Print only warnings and errors during test
config :logger, level: :warn

config :joken, default_signer: "JWT_SECRET"
