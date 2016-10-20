defmodule Revenant.Schema.User do
  use Ecto.Schema

  schema "users" do
    field :email, :string
    field :name, :string
    field :crypted_password, :string
    field :steam_id, :string

    has_many :servers, Revenant.Schema.Server
    has_many :bans, Revenant.Schema.Ban

    timestamps
  end
end
