defmodule Revenant.Query.Server do
  import Ecto.Query
  alias Revenant.Repo
  alias Revenant.Schema.Server

  def find(server_id) do
    query = from s in Server, where: s.id == ^server_id
    Repo.one query
  end
end
