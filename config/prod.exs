use Mix.Config

config :revenant, Revenant.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "revenant_prod",
  username: "revenant",
  password: System.get_env("REVENANT_DB_PASSWORD"),
  host: System.get_env("REVENANT_DB_HOST"),
  port: System.get_env("REVENANT_DB_PORT")
