defmodule Revenant.Schema.User do
  use Ecto.Schema

  schema "users" do
    field :email, :string
    field :name, :string
    field :crypted_password, :string
    field :steam_id, :string

    has_many :servers, Revenant.Schema.Server, foreign_key: :owner_id
    has_many :bans, Revenant.Schema.Ban, foreign_key: :banned_by_id

    timestamps()
  end
end
