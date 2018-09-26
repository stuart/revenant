defmodule Revenant.Schema.Chat do
  use Ecto.Schema

  schema "chats" do
    field :user
    field :message

    belongs_to :server, Revenant.Schema.Server

    timestamps()
  end
end
