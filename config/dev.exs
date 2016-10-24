use Mix.Config

config :revenant, Revenant.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "revenant_dev",
  username: "postgres",
  password: "postgres",
  host: "localhost",
  port: "5432"
