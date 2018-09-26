defmodule Revenant.Schema.ScheduledMessage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "scheduled_messages" do
    field :message, :string
    field :repeat_rate, :integer

    belongs_to :server, Revenant.Schema.Server
    timestamps()

  end

  def create server_id, message, repeat_rate do
    cs = changeset(%__MODULE__{}, %{server_id: server_id, message: message, repeat_rate: repeat_rate})
    Revenant.Repo.insert(cs)
  end

  defp changeset(scheduled_message, params) do
    scheduled_message
    |> cast(params, [:server_id, :message, :repeat_rate])
    |> validate_required([:server_id, :message, :repeat_rate])
    |> validate_number(:repeat_rate, greater_than: 10)
  end
end
