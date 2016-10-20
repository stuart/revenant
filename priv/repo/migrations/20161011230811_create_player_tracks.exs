defmodule Revenant.Repo.Migrations.CreateTracks do
  use Ecto.Migration

  def change do
    create table(:tracks) do
      add :player_id, :integer
      add :x, :float
      add :y, :float
      add :z, :float

      timestamps
    end

    create index(:tracks, :player_id)
  end
end
