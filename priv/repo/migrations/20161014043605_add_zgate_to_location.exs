defmodule Revenant.Repo.Migrations.AddZgateToLocation do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add :zgate, :boolean
    end
  end
end
