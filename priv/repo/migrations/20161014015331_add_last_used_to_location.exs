defmodule Revenant.Repo.Migrations.AddLastUsedToLocation do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add :last_used, :datetime
    end
  end
end
