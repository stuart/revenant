defmodule Revenant.Query.User do
  import Ecto.Query
  alias Revenant.Repo
  alias Revenant.Schema.User

  def find_by_name(name) do
    query = from u in User, where: u.name == ^name
    Repo.all query
  end
end
