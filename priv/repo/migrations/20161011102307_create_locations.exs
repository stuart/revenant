defmodule Revenant.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :server_id, :integer
      add :player_id, :integer
      add :name, :string
      add :x, :float
      add :y, :float
      add :z, :float
      add :radius, :float
      add :description, :string
      add :public, :bool

      timestamps
    end

    create index(:locations, [:server_id])
    create index(:locations, [:player_id])

    create unique_index(:locations, [:name, :server_id], name: :locations_name_server_id_index)
    create unique_index(:locations, [:name, :player_id], name: :locations_name_player_id_index)
  end
end
