defmodule Revenant do
  use Application
  require Logger

  def start(_type, _args) do
    Logger.info "Starting Revenant application"
    Revenant.Supervisor.start_link()
  end
end
