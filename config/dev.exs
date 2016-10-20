use Mix.Config

config :revenant, Revenant.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "revenant",
  username: "postgres",
  password: "postgres",
  host: "localhost",
  port: "5432"
