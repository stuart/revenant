defmodule Revenant.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :name, :string
      add :steam_id, :string
      add :crypted_password, :string

      timestamps
    end

    create index(:users, [:name])
    create index(:users, [:email])
    create index(:users, [:steam_id])
  end
end
