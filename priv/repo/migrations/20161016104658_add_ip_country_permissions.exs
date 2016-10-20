defmodule Revenant.Repo.Migrations.AddIpCountryPermissions do
  use Ecto.Migration

  def change do
    alter table(:servers) do
      add :ip_permissions, :map
      add :country_permissions, :map
    end
  end
end
