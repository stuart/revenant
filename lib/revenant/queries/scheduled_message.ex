defmodule Revenant.Query.ScheduledMessage do
  import Ecto.Query
  alias Revenant.Repo
  alias Revenant.Schema.ScheduledMessage

  def find_by_server_id(server_id) do
    query = from s in ScheduledMessage, where: s.server_id == ^server_id
    Repo.all query
  end
end
