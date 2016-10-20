defmodule Revenant.ChatLogger do
  use GenServer

  def start_link(socket_pid, server_id) do
    GenServer.start_link(__MODULE__, [socket_pid, server_id], name: :"#{__MODULE__}.#{server_id}")
  end

  def init([socket_pid, server_id]) do
    Revenant.ServerSocket.register_listener socket_pid, %{mfa: {__MODULE__, :log, [self]}, streams: [:chat]}
    send self(), {:startup_message, socket_pid}
    {:ok, server_id}
  end

  def log(pid, line) do
    GenServer.cast pid, {:log, line}
  end

  def handle_cast({:log, %{chat: %{message: message, user: user}}}, server_id) do
    Revenant.Repo.insert %Revenant.Schema.Chat{message: message, user: user, server_id: server_id}
    {:noreply, server_id}
  end

  def handle_info({:startup_message, socket}, state) do
    Revenant.ServerSocket.say socket, "[REVENANT] Chat logger started."
    {:noreply, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end
end
