defmodule Revenant.Schema.Ban do
  use Ecto.Schema

  schema "bans" do
    field :start_time, Ecto.DateTime
    field :duration, :integer
    field :reason, :string

    has_one :banned_by, Revenant.Schema.User
    has_one :server, Revenant.Schema.Server

    timestamps
  end
end
