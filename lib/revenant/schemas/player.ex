defmodule Revenant.Schema.Player do
  use Ecto.Schema
  import Ecto.Changeset
  alias Revenant.Repo

  schema "players" do
    field :name, :string
    field :last_connected,  :naive_datetime
    field :hours_played, :float
    field :health, :integer
    field :deaths, :integer
    field :zombie_kills, :integer
    field :player_kills, :integer
    field :level, :integer
    field :score, :integer

    belongs_to :server, Revenant.Schema.Server
    belongs_to :user, Revenant.Schema.User, foreign_key: :steam_id, type: :string

    has_many :inventories, Revenant.Schema.Inventory

    timestamps()
  end

  def changeset(player, params \\ %{}) do
    player
    |> cast(params, allowed_params())
    |> validate_required([:name, :steam_id, :server_id, :inventories])
    |> unique_constraint(:steam_id, name: :players_steam_id_server_id_index)
  end

  def update_changeset(player, params \\ %{}) do
    player
    |> cast(params, update_params())
    |> validate_required([:name, :steam_id, :server_id])
    |> unique_constraint(:steam_id, name: :players_steam_id_server_id_index)
  end

  def from_player_info(server_id, player_info) do
    case Revenant.Query.Player.by_server_and_steam_id(server_id, player_info.steam_id) do
      nil ->
        changeset = changeset(%__MODULE__{}, Map.merge(player_info, %{server_id: server_id,
          inventories: [%{name: "bag", items: []}, %{name: "belt", items: []}, %{name: "equipment", items: []}]}))
        if changeset.valid? do
          Repo.insert(changeset)
        else
          IO.inspect changeset.errors
        end

      existing_player ->
        changeset = update_changeset(existing_player, Map.merge(player_info, %{server_id: server_id}))
        if changeset.valid? do
          Repo.update(changeset)
        else
          IO.inspect changeset.errors
        end
    end
  end

  defp allowed_params() do
    [ :name,
      :steam_id,
      :server_id,
      :last_connected,
      :hours_played,
      :health,
      :deaths,
      :zombie_kills,
      :player_kills,
      :level,
      :score
    ]
  end

  defp update_params() do
    [ :name,
      :last_connected,
      :hours_played,
      :health,
      :deaths,
      :zombie_kills,
      :player_kills,
      :level,
      :score
    ]
  end

end
