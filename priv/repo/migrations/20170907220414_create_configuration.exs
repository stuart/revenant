defmodule Revenant.Repo.Migrations.CreateConfiguration do
  use Ecto.Migration

  def change do
    create table(:configuration) do
      add :name, :string, default: "Configuration"
      add :server_id, :integer


      timestamps
    end

    create index(:servers, [:name])
  end
end
