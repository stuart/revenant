defmodule Revenant.Worker.Zgate do
  use Revenant.Worker.Simple
  alias Revenant.Schema.Player

  def handle_command(state = %State{args: ["list"], user: "Server"}) do
    gates = Revenant.Query.Location.server_gates(state.server_id)
    Revenant.ServerSocket.pm state.socket, state.user, server_gate_message(gates)
    :done
  end

  def handle_command(state = %State{args: ["list"]}) do
    %Player{id: player_id} = Revenant.Query.Player.by_server_and_name(state.server_id, state.user)
    gates = Revenant.Query.Location.player_gates(player_id)
    Revenant.ServerSocket.pm state.socket, state.user, gate_message(gates)
    :done
  end

  def handle_command(state = %State{args: ["list", "public"]}) do
    gates = Revenant.Query.Location.public_gates(state.server_id)
    Revenant.ServerSocket.pm state.socket, state.user, gate_message(gates)
    :done
  end

  def handle_command(state = %State{args: ["delete", name]}) do
    %Player{id: player_id} = Revenant.Query.Player.by_server_and_name(state.server_id, state.user)

    case Revenant.Query.Location.find_gate(name, state.server_id, player_id) do
      nil ->
        Revenant.ServerSocket.pm state.socket, state.user, no_gate_message(name)
      gate ->
        Revenant.Repo.delete(gate)
        Revenant.ServerSocket.pm state.socket, state.user, delete_gate_message(gate)
    end
    :done
  end

  def handle_command(state = %State{user: "Server", args: ["toggle", name]}) do
    do_toggle_gate(name, state, nil)
    :done
  end

  def handle_command(state = %State{args: ["toggle", name]}) do
    %Player{id: player_id} = Revenant.Query.Player.by_server_and_name(state.server_id, state.user)
    do_toggle_gate(name, state, player_id)
    :done
  end

  def handle_command(state = %State{args: [name | _rest]}) do
    %Player{id: player_id} = Revenant.Query.Player.by_server_and_name(state.server_id, state.user)

    do_visit_gate(name, state, player_id)
    :done
  end

  def handle_command(_) do
    :done
  end

  def do_toggle_gate(name, state, player_id) do
    case Revenant.Query.Location.find_gate(name, state.server_id, player_id) do
      nil ->
        Revenant.ServerSocket.pm state.socket, state.user, no_gate_message(name)
      gate ->
        {:ok, new_gate} = Revenant.Schema.Location.toggle(gate)
        Revenant.ServerSocket.pm state.socket, state.user, toggle_gate_message(new_gate)
    end
  end

  def do_visit_gate(name, state, player_id) do
    case Revenant.Query.Location.available_gate(name, state.server_id, player_id) do
      nil ->
        Revenant.ServerSocket.pm state.socket, state.user, no_gate_message(name)
      gate ->
        do_teleport(gate, state.user, state.socket)
    end
  end

  defp do_teleport(gate, user, socket) do
    Revenant.ServerSocket.pm socket, user, gate_visit_message(gate)
    Revenant.ServerSocket.post socket, "teleportplayer \"#{user}\" #{round gate.x} #{round gate.y} #{round gate.z}"
    Revenant.Schema.Location.used(gate)
  end

  defp gate_message([]) do
    "[ccccff]No zGates to show."
  end

  defp gate_message(gates) do
    "[ccccff]Listing zGates:\n" <> (gates
                            |> Enum.map(&format_gate(&1))
                            |> Enum.join("/n"))
  end

  defp format_gate(gate = %{public: true}) do
    "[cccccc]#{gate.name} - public."
  end

  defp format_gate(gate = %{public: false}) do
    "[cccccc]#{gate.name} - private."
  end

  defp delete_gate_message(gate) do
    "[cccccc]Deleted the #{gate.name} zgate."
  end

  defp no_gate_message(name) do
    "[ccccff]Cannot find the gate: #{name}."
  end

  defp toggle_gate_message(gate = %{public: true}) do
    "[cccccc]Toggled the #{gate.name} gate to public."
  end

  defp toggle_gate_message(gate = %{public: false}) do
    "[cccccc]Toggled the #{gate.name} gate to private."
  end

  defp gate_visit_message gate do
    "[cccccc]Teleporting you to the #{gate.name} gate"
  end

  defp server_gate_message(gates) do
    "Listing zGates:\n" <> (gates
              |> Enum.map(&format_server_gate(&1))
              |> Enum.join("/n"))
  end

  defp format_server_gate(gate) do
    "#{gate.name}: player: #{gate.player_id}, pos: (#{gate.x} #{gate.y} #{gate.z}), public: #{gate.public}, last_used: #{gate.last_used}"
  end
end
