defmodule Revenant.Repo.Migrations.CreateServers do
  use Ecto.Migration

  def change do
    create table(:servers) do
      add :name, :string
      add :host, :string
      add :telnet_port, :integer
      add :telnet_password, :string
      add :owner_id, :integer

      timestamps
    end

    create index(:servers, [:name])
  end
end
