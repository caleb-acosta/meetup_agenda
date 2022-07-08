defmodule MeetupAgenda.Repo do
  use Ecto.Repo,
    otp_app: :meetup_agenda,
    adapter: Ecto.Adapters.Postgres
end
