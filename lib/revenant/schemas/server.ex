defmodule Revenant.Schema.Server do
  use Ecto.Schema
  import Ecto.Changeset

  schema "servers" do
    field :name, :string
    field :host, :string, default: "localhost"
    field :telnet_port, :integer
    field :telnet_password, :string
    field :motd, :string
    field :new_player_message, :string
    field :ping_limit, :integer, default: 500

    belongs_to :owner, Revenant.Schema.User

    has_many :players, Revenant.Schema.Player
    has_many :locations, Revenant.Schema.Location
    has_many :chats, Revenant.Schema.Chat
    embeds_one :ip_permissions, Revenant.Schema.Permissions
    embeds_one :country_permissions, Revenant.Schema.Permissions

    timestamps
  end

  def changeset(server, params \\ %{}) do
    server
    |> cast(params, [:name, :host, :telnet_port, :telnet_password, :ip_permissions, :country_permissions])
    |> validate_required([:name, :host, :telnet_port, :telnet_password])
    |> validate_inclusion(:telnet_port, 1000..9999)
    |> unique_constraint(:name)
  end
end


defmodule Revenant.Schema.Permissions do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "permissions" do
    field :blacklist, {:array, :string}, default: []
    field :whitelist, {:array, :string}, default: []
    field :whitelist_enabled, :boolean, default: false
  end
end
