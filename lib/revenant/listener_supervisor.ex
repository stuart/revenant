defmodule Revenant.ListenerSupervisor do
  use Supervisor

  def start_link socket, server_id do
     Supervisor.start_link(__MODULE__, [socket, server_id], name: :"#{__MODULE__}.#{server_id}")
   end

   def init([socket, server_id]) do
     children = [
       worker(Revenant.ChatLogger, [socket, server_id]),
       worker(Revenant.CommandHandler, [socket, server_id]),
       worker(Revenant.PlayerTracker, [socket, server_id]),
       worker(Revenant.LoginTracker, [socket, server_id]),
     ]

     supervise(children, strategy: :one_for_one)
   end
end
