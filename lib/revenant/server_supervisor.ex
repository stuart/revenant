defmodule Revenant.ServerSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    servers = Revenant.Repo.all(Revenant.Schema.Server)

    servers
    |> Enum.map(fn(server) -> supervisor(Revenant.Server, [server], restart: :permanent) end)
    |> supervise(strategy: :one_for_one)
  end
end
