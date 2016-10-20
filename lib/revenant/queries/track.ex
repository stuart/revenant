defmodule Revenant.Query.Track do
  import Ecto.Query
  alias Revenant.Repo
  alias Revenant.Schema.Track
  alias Revenant.Schema.Player

  def players_near_position(server_id, {x,y,z}) do
    who_distance = Application.get_env(:revenant, :who_distance)
    sq_who_distance = who_distance * who_distance

    query = from t in Track,
        distinct: true,
        where: fragment("(? - ?)^2 + (? - ?)^2 + (? - ?)^2 < ?", t.x, ^x, t.y, ^y, t.z, ^z, ^sq_who_distance),
        join: p in Player, where: p.server_id == ^server_id and t.player_id == p.id,
        select: p.name
    Repo.all(query)
  end
end
