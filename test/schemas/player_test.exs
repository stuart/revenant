defmodule PlayerTest do
  use ExUnit.Case

  alias Revenant.Schema.Player

  test "can create a player from playerinfo" do
    server_id = 1
    player_info = %{deaths: 9, health: 28, ip: {59, 167, 155, 186}, level: 10,
                  ping: 28, player_kills: 0, position: {3740.4, 131.4, 3533.1},
                  rotation: {-36.6, 177.2, 0.0}, score: 10, steam_id: "761111111111111111",
                  name: "Doc Saturn", zombie_kills: 34}

    assert {:ok, %Player{name: "Doc Saturn"}} = Player.from_player_info(server_id, player_info)
  end
end
