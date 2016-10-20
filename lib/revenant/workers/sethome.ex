defmodule Revenant.Worker.Sethome do
  use Revenant.Worker.Listener

  def streams do
    [:playerinfo]
  end

  def post_request(state) do
    Revenant.ServerSocket.post state.socket, "lp"
  end

  def handle_command(%{playerinfo: %{name: user, steam_id: steam_id, position: position}, type: :playerinfo}, %State{user: user, socket: socket, server_id: server_id}) do
    case Revenant.Query.Player.by_server_and_steam_id(server_id, steam_id) do
      nil ->
        Logger.warn "Unknown player sent /sethome"
      player = %Revenant.Schema.Player{} ->
        Revenant.Schema.Location.set_player_home(player.id, server_id, position)
        Revenant.ServerSocket.pm socket, user, "Your home position has been set."
    end
    :done
  end

  def handle_command(_, _) do
  end
end
