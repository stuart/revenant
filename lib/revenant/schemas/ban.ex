defmodule Revenant.Schema.Ban do
  use Ecto.Schema

  schema "bans" do
    field :start_time,  :naive_datetime
    field :duration, :integer
    field :reason, :string

    belongs_to :banned_by, Revenant.Schema.User
    belongs_to :server, Revenant.Schema.Server

    timestamps()
  end
end
