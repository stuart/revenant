defmodule Revenant.Query.Player do
  import Ecto.Query
  alias Revenant.Repo
  alias Revenant.Schema.Player

  def by_server_and_steam_id(server_id, steam_id) do
    query = from p in Player,
              where: p.steam_id == ^steam_id,
              where: p.server_id == ^server_id

    Repo.one(query)
  end

  def by_server_and_name(server_id, name) do
    query = from p in Player,
              where: p.name == ^name,
              where: p.server_id == ^server_id

    Repo.one(query)
  end

  def find_inventory(player_id, inventory_name) do
    query = from i in Revenant.Schema.Inventory,
      where: i.player_id == ^player_id,
      where: i.name == ^inventory_name

    Repo.one(query)
  end
end
