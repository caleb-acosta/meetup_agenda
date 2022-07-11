defmodule MeetupAgendaWeb.EventLiveTest do
  use MeetupAgendaWeb.ConnCase

  import Phoenix.LiveViewTest
  import MeetupAgenda.AgendaServiceFixtures

  @create_attrs %{description: "some description", event_date: %{day: 10, month: 7, year: 2022}, title: "some title"}
  @update_attrs %{description: "some updated description", event_date: %{day: 11, month: 7, year: 2022}, title: "some updated title"}
  @invalid_attrs %{description: nil, event_date: %{day: 30, month: 2, year: 2022}, title: nil}

  defp create_event(_) do
    event = event_fixture()
    %{event: event}
  end

  describe "Index" do
    setup [:create_event]

    test "lists all events", %{conn: conn, event: event} do
      {:ok, _index_live, html} = live(conn, Routes.event_index_path(conn, :index))

      assert html =~ "Listing Events"
      assert html =~ event.description
    end

    test "saves new event", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.event_index_path(conn, :index))

      assert index_live |> element("a", "New Event") |> render_click() =~
               "New Event"

      assert_patch(index_live, Routes.event_index_path(conn, :new))

      assert index_live
             |> form("#event-form", event: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#event-form", event: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.event_index_path(conn, :index))

      assert html =~ "Event created successfully"
      assert html =~ "some description"
    end

    test "updates event in listing", %{conn: conn, event: event} do
      {:ok, index_live, _html} = live(conn, Routes.event_index_path(conn, :index))

      assert index_live |> element("#event-#{event.id} a", "Edit") |> render_click() =~
               "Edit Event"

      assert_patch(index_live, Routes.event_index_path(conn, :edit, event))

      assert index_live
             |> form("#event-form", event: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#event-form", event: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.event_index_path(conn, :index))

      assert html =~ "Event updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes event in listing", %{conn: conn, event: event} do
      {:ok, index_live, _html} = live(conn, Routes.event_index_path(conn, :index))

      assert index_live |> element("#event-#{event.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#event-#{event.id}")
    end
  end

  describe "Show" do
    setup [:create_event]

    test "displays event", %{conn: conn, event: event} do
      {:ok, _show_live, html} = live(conn, Routes.event_show_path(conn, :show, event))

      assert html =~ "Show Event"
      assert html =~ event.description
    end

    test "updates event within modal", %{conn: conn, event: event} do
      {:ok, show_live, _html} = live(conn, Routes.event_show_path(conn, :show, event))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Event"

      assert_patch(show_live, Routes.event_show_path(conn, :edit, event))

      assert show_live
             |> form("#event-form", event: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        show_live
        |> form("#event-form", event: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.event_show_path(conn, :show, event))

      assert html =~ "Event updated successfully"
      assert html =~ "some updated description"
    end
  end
end
