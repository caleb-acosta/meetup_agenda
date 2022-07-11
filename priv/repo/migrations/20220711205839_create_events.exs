defmodule MeetupAgenda.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :title, :string
      add :description, :string
      add :event_date, :date

      timestamps()
    end
  end
end
