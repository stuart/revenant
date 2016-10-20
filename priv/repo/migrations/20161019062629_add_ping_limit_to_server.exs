defmodule Revenant.Repo.Migrations.AddPingLimitToServer do
  use Ecto.Migration

  def change do
    alter table(:servers) do
      add :ping_limit, :integer
    end
  end
end
