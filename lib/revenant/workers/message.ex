defmodule Revenant.Worker.Message do
  require Logger
  use GenServer
  alias Revenant.Schema.ScheduledMessage

  def start_link(scheduled_message, socket) do
    GenServer.start_link(__MODULE__, {scheduled_message, socket})
  end

  def init({%ScheduledMessage{message: message, repeat_rate: repeat_rate}, socket}) do
    :timer.apply_interval(repeat_rate * 1000, GenServer, :cast, [self(), :message])
    {:ok, {message, socket}}
  end

  def handle_cast(:message, {message, socket}) do
    Revenant.ServerSocket.say socket, message
    {:noreply, {message, socket}}
  end
end
