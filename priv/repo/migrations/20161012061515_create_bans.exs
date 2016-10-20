defmodule Revenant.Repo.Migrations.CreateBans do
  use Ecto.Migration

  def change do
    create table(:bans) do
      add :start_time, :datetime
      add :duration, :integer
      add :reason, :string
      add :banned_by_id, :integer
      add :server_id, :integer

      timestamps
    end

    create index(:bans, :server_id)
  end
end
