defmodule :"Elixir.Revenant.Repo.Migrations.Add MOTD to server" do
  use Ecto.Migration

  def change do
    alter table(:servers) do
      add :motd, :string
      add :new_player_message, :string
    end
  end
end
