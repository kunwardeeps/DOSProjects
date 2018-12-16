# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :dosProject4B,
  ecto_repos: [DosProject4B.Repo]

# Configures the endpoint
config :dosProject4B, DosProject4BWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "C3oyhcYT0d6WgcV/aOX/5OdVBmch+tDFmLFdSIit7DmNtHhlwG0HxeLYx3C7JUBF",
  render_errors: [view: DosProject4BWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: DosProject4B.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
