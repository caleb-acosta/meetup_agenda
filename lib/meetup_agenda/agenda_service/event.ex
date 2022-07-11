defmodule MeetupAgenda.AgendaService.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :description, :string
    field :event_date, :date
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:title, :description, :event_date])
    |> validate_required([:title, :description, :event_date])
  end
end
