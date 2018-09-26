defmodule Revenant.LoginTracker do
  use GenServer
  require Logger

  defstruct server_id: nil, player_list: [], socket: nil

  def start_link(socket, server_id) do
    GenServer.start_link(__MODULE__, {socket, server_id}, name: :"#{__MODULE__}.#{server_id}")
  end

  def init({socket, server_id}) do
    Revenant.ServerSocket.register_listener socket, %{mfa: {__MODULE__, :track, [self()]}, streams: [:connection, :disconnection]}
    Revenant.ServerSocket.say socket, "[REVENANT] Login Tracker started."
    {:ok, %__MODULE__{socket: socket, server_id: server_id}}
  end

  def track(pid, message) do
    GenServer.cast pid, {:track, message}
  end

  def handle_cast({:track, %{connection: %{ip: ip, name: name, steam_id: steam_id}}}, state) do
    server = Revenant.Query.Server.find(state.server_id)

    case Revenant.IPCheck.check(ip, server) do
      :ok ->
          case Revenant.Query.Player.by_server_and_steam_id(state.server_id, steam_id) do
            nil ->
                Logger.info("New player: #{name}")
                Process.send_after(self(), {:new_player_login, name},
                                   Application.get_env(:revenant, :login_message_delay))
            _ ->
                Logger.info("Returning player #{name}")
                Process.send_after(self(), {:returning_player_login, name},
                                   Application.get_env(:revenant, :login_message_delay))
            end
      {:error, reason} ->
          Revenant.ServerSocket.say state.socket, "[REVENANT] #{reason}"
          Revenant.ServerSocket.post state.socket, "kick \"#{name}\" \"#{reason}\""
    end
    {:noreply, state}
  end

  def handle_cast({:track, %{disconnection: _}}, state) do
    {:noreply, state}
  end

  def handle_info({:new_player_login, name}, state) do
    server = Revenant.Query.Server.find(state.server_id)

    Revenant.ServerSocket.pm state.socket, name, server.new_player_message
    Revenant.ServerSocket.pm state.socket, name, server.motd
    {:noreply, state}
  end

  def handle_info({:returning_player_login, name}, state) do
    server = Revenant.Query.Server.find(state.server_id)

    Revenant.ServerSocket.pm state.socket, name, server.motd
    {:noreply, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end
end
