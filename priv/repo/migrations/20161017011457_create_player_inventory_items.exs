defmodule Revenant.Repo.Migrations.CreatePlayerInventory do
  use Ecto.Migration

  def change do
    create table(:inventories) do
      add :player_id, :integer
      add :name, :string
      add :items, {:array, :map}, default: []
    end
  end
end
