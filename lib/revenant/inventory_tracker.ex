defmodule Revenant.InventoryTracker do
  use GenServer

  defstruct server_id: nil, socket: nil, current_player: nil, current_inventory: nil

  def start_link(socket, server_id) do
    GenServer.start_link(__MODULE__, {socket, server_id}, name: :"#{__MODULE__}.#{server_id}")
  end

  def init({socket, server_id}) do
    Revenant.ServerSocket.register_listener socket, %{mfa: {__MODULE__, :track, [self()]}, streams: [:playerinfo, :inventory]}
    send self(), {:startup_message, socket}
    {:ok, %__MODULE__{server_id: server_id, socket: socket}}
  end

  def track(pid, player_info) do
    GenServer.cast pid, {:track, player_info}
  end

  def handle_cast({:track, %{playerinfo: player_info}}, state) do
    {:ok, player} = Revenant.Schema.Player.from_player_info(state.server_id, player_info)
    Revenant.ServerSocket.post state.socket, "si \"#{player.name}\""
    {:noreply, %{state | current_player: player, current_inventory: nil}}
  end

  def handle_cast({:track, %{inventory: %{name: name, type: type}}}, state = %{current_player: %{name: name}}) do
    {:noreply, %{state | current_inventory: %{type: type, items: []}}}
  end

  def handle_cast({:track, %{item: item}}, state = %{current_inventory: inv}) do
    {:noreply, %{state | current_inventory: %{inv | items: [item | inv.items]}}}
  end

  def handle_info({:tick, socket}, state) do
    Process.send_after(self(), {:tick, socket}, Application.get_env(:revenant, :inventory_tracker_interval))
    {:noreply, state}
  end

  def handle_info({:startup_message, socket}, state) do
    Revenant.ServerSocket.say socket, "[REVENANT] Inventory Tracker started."
    send(self(), {:tick, socket})
    {:noreply, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end
end
