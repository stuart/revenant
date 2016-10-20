defmodule Revenant.Worker.Home do
  use Revenant.Worker.Simple

  def handle_command(%State{user: user, server_id: server_id, socket: socket}) do
    case Revenant.Query.Player.by_server_and_name(server_id, user) do
      nil ->
        nil
      player ->
      case Revenant.Query.Location.home(player.id) do
        nil ->
          Revenant.ServerSocket.pm socket, user, no_home_message
        location ->
            halfhourago = (:calendar.datetime_to_gregorian_seconds(:calendar.universal_time) - 1800)
            |> :calendar.gregorian_seconds_to_datetime
          if (Ecto.DateTime.to_erl(location.last_used) < halfhourago) do
            do_teleport(location, user, socket)
          else
            Revenant.ServerSocket.pm socket, user, to_soon_message
          end
      end
    end
  end

  defp do_teleport(location, user, socket) do
    Revenant.ServerSocket.pm socket, user, home_message
    Revenant.ServerSocket.post socket, "teleportplayer \"#{user}\" #{round location.x} #{round location.y} #{round location.z}"
    Revenant.Schema.Location.used(location)
  end

  defp home_message do
    "[cccccc]Teleporting you home."
  end

  defp no_home_message do
    "[cccccc]You have no home set. Use [ccccff]/sethome[cccccc] first."
  end

  defp to_soon_message do
    "[cccccc]You can only use /home once every 30 minutes."
  end
end
