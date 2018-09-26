use Mix.Config

config :revenant, Revenant.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "revenant_test",
  username: "postgres",
  password: "postgres",
  host: "localhost",
  port: "5432"

config :geoip,
  provider: :test,
    test_results: %{
      "123.34.45.67" => %{
        country_code: "AU"
      },
      "123.23.45.3" => %{
        ip: "123,23,45,3",
        country_code: "VN"
      },
      "8.8.8.8" => %{
        ip: "8.8.8.8",
        country_code: "US"
      },
      default_test_result: %{
         country_code: "XX"
      }
     }
