defmodule Revenant.Query.Location do
  import Ecto.Query
  alias Revenant.Repo
  alias Revenant.Schema.Location

  def find_gate(name, server_id, nil) do
    query = from loc in Location,
              where: loc.zgate == true,
              where: loc.server_id == ^server_id,
              where: loc.name == ^name

    Repo.one(query)
  end

  def find_gate(name, server_id, player_id) do
    query = from loc in Location,
              where: loc.zgate == true,
              where: loc.server_id == ^server_id,
              where: loc.player_id == ^player_id,
              where: loc.name == ^name

    Repo.one(query)
  end


  def public(server_id) do
    query = from p in Location,
              where: p.server_id == ^server_id,
              where: p.public == true

    Repo.all(query)
  end

  def home(player_id) do
    query = from loc in Location,
              where: loc.player_id == ^player_id,
              where: loc.name == ^"home_#{player_id}"

    Repo.one(query)
  end

  def player_gates(player_id) do
    Repo.all(player_gates_query(player_id))
  end

  def player_gate_count(player_id) do
    query = from p in player_gates_query(player_id),
      select: count(p.id)

    Repo.one(query)
  end

  def public_gates(server_id) do
    query = from loc in Location,
              where: loc.zgate == true,
              where: loc.server_id == ^server_id and loc.public == true

    Repo.all(query)
  end

  def available_gates(server_id, player_id) do
    Repo.all(available_gates_query(server_id, player_id))
  end

  def available_gate(name, server_id, player_id) do
    query = from loc in available_gates_query(server_id, player_id),
              where: loc.name == ^name

    Repo.one(query)
  end

  def server_gates(server_id) do
    query = from loc in Location,
              where: loc.zgate == true,
              where: loc.server_id == ^server_id

    Repo.all(query)
  end

  defp player_gates_query(player_id) do
    from loc in Location,
        where: loc.zgate == true,
        where: loc.player_id == ^player_id
  end

  defp available_gates_query(server_id, player_id) do
    from loc in Location,
      where: loc.zgate == true,
      where: loc.player_id == ^player_id or (loc.server_id == ^server_id and loc.public == true)
  end
end
