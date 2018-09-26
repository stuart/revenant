defmodule Revenant.Mixfile do
  use Mix.Project

  def project do
    [app: :revenant,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [mod: {Revenant, []}, applications: [:logger, :postgrex, :ecto, :comeonin, :geoip]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:neotomex, "~>0.1.7"},
      {:uuid, "~> 1.1" },
      {:postgrex, ">= 0.0.0"},
      {:ecto, "~> 2.2.0"},
      {:comeonin, "~> 4.1"},
      {:geoip, "~> 0.2"}
    ]
  end
end
