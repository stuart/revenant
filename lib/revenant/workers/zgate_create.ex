defmodule Revenant.Worker.ZgateCreate do
  use Revenant.Worker.Listener
  alias Revenant.Schema.{Player, Location}

  def streams do
    [:playerinfo]
  end

  def post_request(state = %{user: "Server", args: [name,x,y,z]}) do
    Location.create_zgate(name, state.user, nil, state.server_id, {x, y, z})
    Revenant.ServerSocket.pm state.socket, state.user, create_gate_message(name)
  end

  def post_request(state) do
    Revenant.ServerSocket.post state.socket, "lp"
  end

  def handle_command(%{playerinfo: %{name: user, position: {x,y,z}}, type: :playerinfo}, state = %{user: user, args: [name]}) do
    %Player{id: player_id} = Revenant.Query.Player.by_server_and_name(state.server_id, user)
    case Location.create_zgate(name, state.user, player_id, state.server_id, {x, y, z}) do
      {:ok, _} -> Revenant.ServerSocket.pm state.socket, state.user, create_gate_message(name)
      {:error, result} -> Revenant.ServerSocket.pm state.socket, state.user, create_gate_error_message(result, name)
    end
    :done
  end

  def handle_command(_) do
  end

  defp create_gate_message(name) do
    "[cccccc]Zgate #{name} created."
  end

  defp create_gate_error_message(%Ecto.Changeset{errors: [name: {"has already been taken", []}]}, name) do
    "[ccccff]Zgate with name: #{name} has already been taken."
  end

  defp create_zgate_error_message(_, name) do
    "[ccccff]Zgate could not be created."
  end
end
