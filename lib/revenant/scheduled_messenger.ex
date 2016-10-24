defmodule Revenant.ScheduledMessenger do
  use Supervisor

  def start_link(socket, server_id) do
    Supervisor.start_link(__MODULE__, {socket, server_id}, name: :"#{__MODULE__}.#{server_id}")
  end

  def init({socket, server_id}) do
    scheduled_messages = Revenant.Query.ScheduledMessage.find_by_server_id(server_id)
    children = Enum.map(scheduled_messages, fn(message) -> worker(Revenant.Worker.Message, [message, socket]) end)

    supervise(children, strategy: :one_for_one)
  end
end
