defmodule Revenant.Schema.Location do
  use Ecto.Schema
  import Ecto.Changeset

  schema "locations" do
    field :name, :string
    field :x, :float
    field :y, :float
    field :z, :float
    field :radius, :float, default: 0.0
    field :description, :string
    field :public, :boolean, default: false
    field :zgate, :boolean, default: false
    field :last_used, Ecto.DateTime, default: Ecto.DateTime.cast!("2000-01-01T00:00:00Z")

    belongs_to :server, Revenant.Schema.Server
    belongs_to :player, Revenant.Schema.Player

    timestamps
  end

  def changeset(location, params \\ %{}) do
    location
    |> cast(params, allowed_params)
    |> validate_required([:name, :x, :y, :z, :server_id, :last_used])
    |> unique_constraint(:name, name: :locations_name_server_id_index)
  end

  def set_player_home(player_id, server_id, {x, y, z}) do
    case Revenant.Query.Location.home(player_id) do
      nil ->
        cs = changeset(%__MODULE__{}, %{name: "home_#{player_id}",
          x: x, y: y, z: z,
          public: false,
          description: "Player #{player_id}'s home.",
          player_id: player_id,
          server_id: server_id
          })

        {:ok, _} = Revenant.Repo.insert(cs)

      existing_home ->
        cs = changeset(existing_home, %{name: "home_#{player_id}",
          x: x, y: y, z: z })

        {:ok, _} = Revenant.Repo.update(cs)
    end
  end

  def used(location) do
    cs = changeset(location, %{last_used: Ecto.DateTime.utc})
    {:ok, _} = Revenant.Repo.update(cs)
  end

  def create_zgate(name, username, player_id, server_id, {x, y, z}) do
    cs = changeset(%__MODULE__{}, %{name: name,
      x: x, y: y, z: z,
      public: false,
      description: "#{username}'s zgate.'",
      player_id: player_id,
      server_id: server_id,
      zgate: true
      })

    Revenant.Repo.insert(cs)
  end

  def toggle(gate = %{public: public}) do
    cs = changeset(gate, %{public: !public})
    {:ok, _} = Revenant.Repo.update(cs)
  end

  defp allowed_params do
    [:name, :x, :y, :z, :server_id, :player_id, :radius, :description, :public, :last_used, :zgate]
  end
end
