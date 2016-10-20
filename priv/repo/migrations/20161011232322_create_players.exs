defmodule Revenant.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :server_id, :integer
      add :name, :string
      add :steam_id, :string
      add :last_connected, :datetime
      add :hours_played, :float
      add :health, :integer
      add :deaths, :integer
      add :zombie_kills, :integer
      add :player_kills, :integer
      add :level, :integer
      add :score, :integer

      timestamps
    end

    create index(:players, :server_id)
    create index(:players, :steam_id)

    create unique_index(:players, [:steam_id, :server_id], name: :players_steam_id_server_id_index)
  end
end
