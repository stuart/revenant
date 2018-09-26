defmodule Revenant.CommandHandler do
  use GenServer
  import Supervisor.Spec

  require Logger
  alias Revenant.ServerSocket
  alias Revenant.Worker.State

  def start_link(socket, server_id) do
    GenServer.start_link(__MODULE__, {socket, server_id}, name: :"#{__MODULE__}.#{server_id}")
  end

  def command(pid, command) do
    GenServer.cast pid, {:command, command}
  end

  def init({socket, server_id}) do
    ServerSocket.register_listener socket, %{mfa: {__MODULE__, :command, [self()]}, streams: [:chat]}
    {:ok, worker_sup} = Supervisor.start_link([], strategy: :one_for_one, name: :"worker_sup.#{server_id}")

    send self(), :startup_message
    {:ok, {socket, server_id, worker_sup}}
  end

  def terminate(_, {socket, _, _}) do
    ServerSocket.deregister_listener socket, %{mfa: {__MODULE__, :command, [self()]}, streams: [:chat]}
    :ok
  end

  def handle_cast {:command, %{chat: %{message: message, user: user}}}, {socket, server_id, worker_sup} do
    ServerSocket.pm(socket, user, "[REVENANT] Server command received: #{message}")
    do_command(message, {user, socket, server_id, worker_sup})
    {:noreply, {socket, server_id, worker_sup}}
  end

  def handle_cast _, state do
    {:noreply, state}
  end

  def handle_info(:startup_message,  {socket, server_id, worker_sup}) do
    ServerSocket.say socket, "[REVENANT] Command handler started."
    {:noreply, {socket, server_id, worker_sup}}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  # Perform command
  defp do_command "/day", {user, socket, server_id, worker_sup} do
    start_command_worker(Revenant.Worker.Day, {user, socket, server_id, worker_sup}, [])
  end

  defp do_command "/day7", {user, socket, server_id, worker_sup} do
    start_command_worker(Revenant.Worker.Day, {user, socket, server_id, worker_sup}, [])
  end

  defp do_command "/help" <> args, {user, socket, server_id, worker_sup} do
    start_command_worker(Revenant.Worker.Help, {user, socket, server_id, worker_sup}, String.split(args))
  end

  defp do_command "/home", {user, socket, server_id, worker_sup} do
    start_command_worker(Revenant.Worker.Home, {user, socket, server_id, worker_sup}, [])
  end

  defp do_command "/pings", {user, socket, server_id, worker_sup} do
    start_command_worker(Revenant.Worker.Ping, {user, socket, server_id, worker_sup}, [])
  end

  defp do_command "/sethome", {user, socket, server_id, worker_sup} do
    start_command_worker(Revenant.Worker.Sethome, {user, socket, server_id, worker_sup}, [])
  end

  defp do_command "/setbase", {user, socket, server_id, worker_sup} do
    start_command_worker(Revenant.Worker.Sethome, {user, socket, server_id, worker_sup}, [])
  end

  defp do_command "/who", {user, socket, server_id, worker_sup} do
    start_command_worker(Revenant.Worker.Who, {user, socket, server_id, worker_sup}, [])
  end

  defp do_command "/zgate create" <> args, {user, socket, server_id, worker_sup} do
    start_command_worker(Revenant.Worker.ZgateCreate, {user, socket, server_id, worker_sup}, String.split(args))
  end

  defp do_command "/zgate" <> args, {user, socket, server_id, worker_sup} do
    start_command_worker(Revenant.Worker.Zgate, {user, socket, server_id, worker_sup}, String.split(args))
  end

  defp do_command "/wp create" <> args, {user, socket, server_id, worker_sup} do
    start_command_worker(Revenant.Worker.ZgateCreate, {user, socket, server_id, worker_sup}, String.split(args))
  end

  defp do_command "/wp" <> args, {user, socket, server_id, worker_sup} do
    start_command_worker(Revenant.Worker.ZgateCreate, {user, socket, server_id, worker_sup}, String.split(args))
  end

  defp do_command "/shop" <> args, {user, socket, server_id, worker_sup} do
    start_command_worker(Revenant.Worker.Shop, {user, socket, server_id, worker_sup}, String.split(args))
  end

  defp do_command _command, {"Server", _, _, _} do
    # Ignore server messages.
  end

  defp do_command command, {user, socket, _server_id, _worker_supt} do
    ServerSocket.pm(socket, user, "Unknown command: #{command}")
  end

  defp start_command_worker worker_module, {user, socket, server_id, worker_sup}, args do
    worker_state = %State{user: user, socket: socket, server_id: server_id, args: args}
    {:ok, _} = Supervisor.start_child(worker_sup, worker(worker_module, [worker_state], [id: make_ref(), restart: :transient]))
  end
end
