defmodule MeetupAgenda.AgendaServiceTest do
  use MeetupAgenda.DataCase

  alias MeetupAgenda.AgendaService

  describe "events" do
    alias MeetupAgenda.AgendaService.Event

    import MeetupAgenda.AgendaServiceFixtures

    @invalid_attrs %{description: nil, event_date: nil, title: nil}

    @valid_attrs %{
      description: "some description",
      event_date: ~D[2022-07-10],
      title: "some title"
    }
    test "list_events/0 returns all events" do
      event = event_fixture()
      assert AgendaService.list_events() == [event]
    end

    test "list_events_by/3 returns all events with the given month" do
      event = event_fixture()

      assert AgendaService.list_events_by(:month, event.event_date.year, event.event_date.month) ==
               [event]
    end

    test "list_events_by/3 returns all events on the given date" do
      event = event_fixture()
      assert AgendaService.list_events_by(:date, event.event_date) == [event]
    end

    test "get_event!/1 returns the event with given id" do
      event = event_fixture()
      assert AgendaService.get_event!(event.id) == event
    end

    test "create_event/1 with valid data creates a event" do
      assert {:ok, %Event{} = event} = AgendaService.create_event(@valid_attrs)
      assert event.description == "some description"
      assert event.event_date == ~D[2022-07-10]
      assert event.title == "some title"
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = AgendaService.create_event(@invalid_attrs)
    end

    test "create_event_strict/1 with repeated date returns error changeset" do
      {:ok, _event} = AgendaService.create_event_strict(@valid_attrs)
      {:error, changeset} = AgendaService.create_event_strict(@valid_attrs)
      assert !changeset.valid?
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

    test "update_event_strict/2 with repeated date returns error changeset" do
      {:ok, event1} =
        AgendaService.create_event(%{title: "t1", description: "d1", event_date: ~D[2022-07-11]})

      {:ok, event2} =
        AgendaService.create_event(%{title: "t2", description: "d2", event_date: ~D[2022-07-12]})

      {:error, changeset} =
        AgendaService.update_event_strict(event2, %{event_date: event1.event_date})

      assert !changeset.valid?
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
