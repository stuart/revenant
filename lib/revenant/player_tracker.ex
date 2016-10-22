defmodule Revenant.PlayerTracker do
  use GenServer

  defstruct server_id: nil, player_list: [], pings: %{}, ping_limit: 500

  def start_link(socket, server_id) do
    GenServer.start_link(__MODULE__, {socket, server_id}, name: :"#{__MODULE__}.#{server_id}")
  end

  def init({socket, server_id}) do
    server = Revenant.Repo.get(Revenant.Schema.Server, server_id)
    Revenant.ServerSocket.register_listener socket, %{mfa: {__MODULE__, :track, [self]}, streams: [:playerinfo]}
    send self(), {:startup_message, socket}
    {:ok, %__MODULE__{server_id: server_id, ping_limit: server.ping_limit}}
  end

  def track(pid, player_info) do
    GenServer.cast pid, {:track, player_info}
  end

  def ping_average(pid, player_id) do
    GenServer.call pid, {:ping_average, player_id}
  end

  def handle_call({:ping_average, player_id}, state) do
    {_, average} = Map.fetch(state.pings, player_id)
    {:reply, average, state}
  end

  def handle_cast({:track, %{playerinfo: player_info}}, state) do
    # FIXME use cached player from state.
    {:ok, player} = Revenant.Schema.Player.from_player_info(state.server_id, player_info)
    Revenant.Schema.Track.add_for_player(player.id, player_info)

    if Enum.any?(state.player_list, fn(p) -> p.id == player.id end) do
      {:noreply,  %{state | pings: update_pings(player.id, state.pings, player_info.ping)}}
    else
      {:noreply, %{state | player_list: [player | state.player_list], pings: update_pings(player.id, state.pings, player_info.ping)}}
    end
  end

  def handle_info({:tick, socket}, state) do
    Revenant.ServerSocket.post socket, "lp"
    kick_high_ping(state.pings, state.ping_limit, socket)

    Process.send_after(self, {:tick, socket}, Application.get_env(:revenant, :player_tracker_interval))
    {:noreply, state}
  end

  def handle_info({:startup_message, socket}, state) do
    Revenant.ServerSocket.say socket, "[REVENANT] Player Tracker started."
    send(self(), {:tick, socket})
    {:noreply, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  defp update_pings(player_id, pings, ping) do
    count = Application.get_env(:revenant, :ping_track_count)

    Map.update(pings, player_id, {:lists.duplicate(count, ping), ping},
      fn {pings, _} -> {:lists.droplast([ping | pings]), :lists.sum(pings) / count} end)
  end

  defp kick_high_ping(pings, ping_limit, socket) do
    Map.to_list(pings)
    |> Enum.each(
      fn({player_id, {_, ping_average}}) when ping_average > ping_limit ->
        player = Revenant.Repo.get(Revenant.Schema.Player, player_id)
        Revenant.ServerSocket.post socket, "kick \"#{player.name}\" \"Ping too high.\""
      _ -> nil
      end)
  end
end
