defmodule Revenant.Repo.Migrations.CreateChats do
  use Ecto.Migration

  def change do
    create table(:chats) do
      add :user, :string
      add :message, :string
      add :server_id, :integer

      timestamps
    end

    create index(:chats, :server_id)
  end
end
