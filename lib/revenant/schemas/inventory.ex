defmodule Revenant.Schema.Inventory do
  use Ecto.Schema
  import Ecto.Changeset
  alias Revenant.Repo

  schema "inventories" do
    field :name, :string
    embeds_many :items, Revenant.Schema.Item, on_replace: :delete
    belongs_to :player, Revenant.Schema.Player
  end

  def changeset(inventory, params \\ %{}) do
    inventory
    |> cast(params, [:name, :player_id])
    |> cast_embed(:items)
  end

  def add_item(inventory, item) do
    cs = changeset(inventory, %{}) |> Ecto.Changeset.put_embed(:items, [item])
    Repo.update(cs)
  end

  def clear(inventory) do
    cs = changeset(inventory, %{}) |> Ecto.Changeset.put_embed(:items, [])
    Repo.update(cs)
  end
end

defmodule Revenant.Schema.Item do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :name, :string
    field :quantity, :integer
    field :slot, :integer
  end

  def changeset(item, params) do
    item
    |> cast(params, [:name, :quantity, :slot])
    |> validate_required([:name, :quantity, :slot])
  end
end
