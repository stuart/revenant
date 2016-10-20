defmodule Revenant.Server do
  use Supervisor
  require Logger
  def start_link server do
     Logger.info "Server starting: #{server.id} - #{server.name}"
     Supervisor.start_link(__MODULE__, server, name: :"#{__MODULE__}.#{server.id}")
   end

   def init(server) do
     {:ok, host} = server.host |> to_charlist |>  :inet.parse_address

     children = [
       worker(Revenant.ServerSocket, [self(), host, server.telnet_port, server.telnet_password, server.id])
     ]

     supervise(children, strategy: :one_for_all)
   end
end
