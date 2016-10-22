# This is the top level application supervisor.
defmodule Revenant.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [supervisor(Revenant.Repo, []),
      supervisor(Revenant.ServerSupervisor, [])]

    supervise(children, strategy: :one_for_one)
  end
end
