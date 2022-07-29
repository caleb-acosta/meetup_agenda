defmodule MeetupAgendaWeb.EventLiveTest do
  use MeetupAgendaWeb.ConnCase

  import Phoenix.LiveViewTest
  import MeetupAgenda.AgendaServiceFixtures

  @create_attrs %{
    title: "event title",
    description: "event description",
    ordinal_day: "1",
    day: "1",
    month: "1",
    year: Timex.today().year |> Integer.to_string()
  }
  @update_attrs %{
    description: "event updated description",
    title: "some updated title",
    ordinal_day: "2",
    day: "2",
    month: "2",
    year: Timex.today().year |> Integer.to_string()
  }
  @invalid_attrs %{
    description: nil,
    title: nil,
    ordinal_day: "1",
    day: "1",
    month: "1",
    year: Timex.today().year |> Integer.to_string()
  }

  defp create_event(_) do
    event = event_fixture()
    %{event: event}
  end

  describe "Index" do
    setup [:create_event]

    test "lists all events", %{conn: conn, event: event} do
      {:ok, _index_live, html} = live(conn, Routes.event_index_path(conn, :index))

      assert html =~ "Listing Events"
      assert html =~ event.title
    end

    test "saves new event", %{conn: conn} do
      {:ok, index_live, html} = live(conn, Routes.event_index_path(conn, :index))

      refute html =~ "modal is-active"

      assert index_live |> element("a", "New Event") |> render_click() =~
               "modal is-active"

      assert_patch(index_live, Routes.event_index_path(conn, :new))

      assert index_live
             |> form("[data-phx-component] form", event: @invalid_attrs)
             |> render_submit =~ "can&#39;t be blank"

      index_live
      |> form("[data-phx-component] form", event: @create_attrs)
      |> render_submit()

      assert render(index_live) =~ "Event created successfully"
    end

    test "updates event in listing", %{conn: conn, event: event} do
      {:ok, index_live, _html} = live(conn, Routes.event_index_path(conn, :index))

      assert index_live
             |> element("[href=\"\/events\/#{event.id}\/edit\"]", "Edit")
             |> render_click() =~
               "Edit event"

      assert_patch(index_live, Routes.event_index_path(conn, :edit, event))

      index_live
      |> form("[data-phx-component] form", event: @update_attrs)
      |> render_submit()

      assert render(index_live) =~ "Event updated successfully"
    end

    test "deletes event in listing", %{conn: conn, event: event} do
      {:ok, index_live, _html} = live(conn, Routes.event_index_path(conn, :index))

      assert index_live |> element("[phx-value-id=#{event.id}]", "Delete") |> render_click()
      refute has_element?(index_live, "#event-#{event.id}")
    end
  end

  describe "Show" do
    setup [:create_event]

    test "displays event", %{conn: conn, event: event} do
      {:ok, _show_live, html} = live(conn, Routes.event_index_path(conn, :show, event))

      assert html =~ "Show Event"
      assert html =~ event.description
    end

    test "updates event within modal", %{conn: conn, event: event} do
      {:ok, show_live, html} = live(conn, Routes.event_index_path(conn, :show, event))

      assert html =~ event.description
      element(show_live, ".is-primary[href]", "Edit") |> render_click()
      assert_patch(show_live, Routes.event_index_path(conn, :edit, event))

      assert show_live
             |> form("[data-phx-component] form", event: @invalid_attrs)
             |> render_submit() =~ "can&#39;t be blank"

      show_live
      |> form("[data-phx-component] form", event: @update_attrs)
      |> render_submit()

      assert render(show_live) =~ "Event updated successfully"
    end
  end

  describe "Modal" do
    test "closes when click close button", %{conn: conn} do
      {:ok, new_live, html} = live(conn, Routes.event_index_path(conn, :new))
      assert html =~ "class=\"modal is-active\""

      refute new_live |> element("[phx-click=modal_close]") |> render_click() =~
               "class=\"modal is-active\""
    end
  end

  describe "Panel" do
    test "switches between tabs", %{conn: conn} do
      {:ok, index_live, html} = live(conn, Routes.event_index_path(conn, :index))
      assert html =~ "<a phx-click=\"switch_tab\" class=\"is-active\" phx-value-index=\"0\">"
      index_live |> element("[phx-value-index=\"1\"]") |> render_click()

      render(index_live) =~
        "<a class=\"is-active\" phx-click=\"switch_tab\" phx-value-index=\"1\">"
    end

    test "change filter month", %{conn: conn} do
      today = Timex.today()

      {:ok, index_live, html} = live(conn, Routes.event_index_path(conn, :index))

      assert html =~ Timex.month_shortname(today.month)

      # Forward
      assert index_live |> element("[phx-click=\"next_month\"]") |> render_click() =~
               Timex.month_shortname(Timex.shift(today, months: 1).month)

      {:ok, index_live, _html} = live(conn, Routes.event_index_path(conn, :index))

      # Backward
      assert index_live |> element("[phx-click=\"prev_month\"]") |> render_click() =~
               Timex.month_shortname(Timex.shift(today, months: -1).month)
    end
  end

  describe "Strict mode" do
    setup [:create_event]

    test "doesn't insert duplicated dates", %{conn: conn, event: event} do
      duplicated_date_event = %{
        title: "event title",
        description: "description",
        ordinal_day: MeetupAgendaWeb.EventLive.FormComponent.ordinal_weekday(event.event_date),
        day: Timex.weekday(event.event_date),
        month: event.event_date.month,
        year: event.event_date.year
      }

      {:ok, index_live, _html} = live(conn, Routes.event_index_path(conn, :index))
      index_live |> element("#strict") |> render_click()

      index_live |> element("a", "New Event") |> render_click()

      index_live
      |> form("[data-phx-component] form", event: duplicated_date_event)
      |> render_submit()

      assert render(index_live) =~ "has already been taken"
    end

    test "doesn't update duplicated dates", %{conn: conn, event: event} do
      {:ok, new_event} =
        MeetupAgenda.AgendaService.create_event(
          Map.update!(event, :event_date, &Timex.shift(&1, days: 1))
          |> Map.from_struct()
        )

      duplicated_date_event = %{
        title: new_event.title,
        description: new_event.description,
        ordinal_day: MeetupAgendaWeb.EventLive.FormComponent.ordinal_weekday(event.event_date),
        day: Timex.weekday(event.event_date),
        month: event.event_date.month,
        year: event.event_date.year
      }

      {:ok, edit_live, _html} = live(conn, Routes.event_index_path(conn, :index))

      edit_live |> element("#strict") |> render_click()

      render_patch(edit_live, Routes.event_index_path(conn, :edit, new_event))

      edit_live
      |> form("[data-phx-component] form", event: duplicated_date_event)
      |> render_submit()

      assert render(edit_live) =~ "has already been taken"
    end
  end
end
