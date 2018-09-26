defmodule Revenant.Schema.Track do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tracks" do
    field :x, :float
    field :y, :float
    field :z, :float
    belongs_to :player, Revenant.Schema.Player

    timestamps()
  end

  def changeset(track, params \\ %{}) do
    track
    |> cast(params, [:x, :y, :z, :player_id])
    |> validate_required([:x, :y, :z, :player_id])
  end

  def add_for_player(player_id, %{position: {x, y, z}}) do
    changeset = changeset(%__MODULE__{}, %{x: x, y: y, z: z, player_id: player_id})
    if changeset.valid? do
      Revenant.Repo.insert(changeset)
    else
      IO.inspect changeset.errors
    end
  end
end
