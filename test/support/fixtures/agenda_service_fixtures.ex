defmodule MeetupAgenda.AgendaServiceFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MeetupAgenda.AgendaService` context.
  """

  @doc """
  Generate a event.
  """
  def event_fixture(attrs \\ %{}) do
    {:ok, event} =
      attrs
      |> Enum.into(%{
        description: "some description",
        event_date: ~D[2022-07-10],
        title: "some title"
      })
      |> MeetupAgenda.AgendaService.create_event()

    event
  end
end
