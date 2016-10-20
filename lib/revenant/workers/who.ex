defmodule Revenant.Worker.Who do
  use Revenant.Worker.Listener

  def streams do
    [:playerinfo]
  end

  def post_request(state) do
    Revenant.ServerSocket.post state.socket, "lp"
  end

  def handle_command(%{playerinfo: %{name: user, position: position}, type: :playerinfo}, state = %{user: user}) do
    players = Revenant.Query.Track.players_near_position(state.server_id, position)
    Revenant.ServerSocket.pm state.socket, user, who_message(players)
    :done
  end

  def handle_command(_, _) do
  end

  defp who_message(players) do
    who_distance = Application.get_env(:revenant, :who_distance)
    "[cccccc]Players who have been within #{who_distance}m in the last 24 hours:\n" <>
    (Enum.map(players, fn(p) -> "[ccccff]#{p}" end) |> Enum.join("\n"))
  end
end
