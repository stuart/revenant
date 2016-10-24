defmodule Revenant.Repo.Migrations.CreateScheduledMessages do
  use Ecto.Migration

  def change do
    create table(:scheduled_messages) do
      add :server_id, :integer
      add :message, :string
      add :repeat_rate, :integer

      timestamps
    end
  end
end
