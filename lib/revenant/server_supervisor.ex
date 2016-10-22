# This supervises each server connection.
defmodule Revenant.ServerSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_server server do
    Supervisor.start_child(__MODULE__,
     supervisor(Revenant.Server, [server],[restart: :permanent, id: :"Revenant.Server.#{server.id}"]))
  end

  def stop_server server do
    Supervisor.terminate_child(__MODULE__, :"Revenant.Server.#{server.id}")
  end

  def init(_) do
    servers = Revenant.Repo.all(Revenant.Schema.Server)

    servers
    |> Enum.map(fn(server) -> supervisor(Revenant.Server, [server], restart: :permanent) end)
    |> supervise(strategy: :one_for_one)
  end
end
