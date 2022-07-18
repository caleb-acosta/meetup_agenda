defmodule MeetupAgenda.AgendaServiceTest do
  use MeetupAgenda.DataCase

  alias MeetupAgenda.AgendaService

  describe "events" do
    alias MeetupAgenda.AgendaService.Event

    import MeetupAgenda.AgendaServiceFixtures

    @invalid_attrs %{description: nil, event_date: nil, title: nil}

    test "list_events/0 returns all events" do
      event = event_fixture()
      assert AgendaService.list_events() == [event]
    end

    test "get_event!/1 returns the event with given id" do
      event = event_fixture()
      assert AgendaService.get_event!(event.id) == event
    end

    test "create_event/1 with valid data creates a event" do
      valid_attrs = %{
        description: "some description",
        event_date: ~D[2022-07-10],
        title: "some title"
      }

      assert {:ok, %Event{} = event} = AgendaService.create_event(valid_attrs)
      assert event.description == "some description"
      assert event.event_date == ~D[2022-07-10]
      assert event.title == "some title"
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = AgendaService.create_event(@invalid_attrs)
    end

    test "update_event/2 with valid data updates the event" do
      event = event_fixture()

      update_attrs = %{
        description: "some updated description",
        event_date: ~D[2022-07-11],
        title: "some updated title"
      }

      assert {:ok, %Event{} = event} = AgendaService.update_event(event, update_attrs)
      assert event.description == "some updated description"
      assert event.event_date == ~D[2022-07-11]
      assert event.title == "some updated title"
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = event_fixture()
      assert {:error, %Ecto.Changeset{}} = AgendaService.update_event(event, @invalid_attrs)
      assert event == AgendaService.get_event!(event.id)
    end

    test "delete_event/1 deletes the event" do
      event = event_fixture()
      assert {:ok, %Event{}} = AgendaService.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> AgendaService.get_event!(event.id) end
    end

    test "change_event/1 returns a event changeset" do
      event = event_fixture()
      assert %Ecto.Changeset{} = AgendaService.change_event(event)
    end
  end
end
