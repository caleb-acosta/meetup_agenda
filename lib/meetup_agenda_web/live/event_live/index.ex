defmodule MeetupAgendaWeb.EventLive.Index do
  @moduledoc """
    MeetupAgenda Root LiveView Module.
  """

  use Surface.LiveView

  alias MeetupAgenda.AgendaService
  alias MeetupAgenda.AgendaService.Event
  alias Surface.Components.LivePatch
  alias SurfaceBulma.{Panel, Modal, Button, Form.Checkbox}
  alias SurfaceBulma.Panel.{Tab, Tab.TabItem}
  alias MeetupAgendaWeb.Router.Helpers, as: Routes
  alias MeetupAgendaWeb.EventLive.{Show, FormComponent, Agenda, Calendar}

  data(events, :list, default: [])
  data(event, :map, default: %Event{event_date: Timex.today()})
  data(strict, :boolean, default: false)
  data(filter_month, :date, default: Timex.today() |> Timex.beginning_of_month())
  data(view, :integer, default: 0)

  @impl true
  def handle_params(params, _url, socket) do
    Panel.set_tab(:panel, socket.assigns.view)
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Event")
    |> assign(:event, AgendaService.get_event!(id))
    |> assign(
      :events,
      list_events(socket.assigns.filter_month.year, socket.assigns.filter_month.month)
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Event")
    |> assign(:event, %Event{event_date: Timex.today()})
    |> assign(
      :events,
      list_events(socket.assigns.filter_month.year, socket.assigns.filter_month.month)
    )
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Events")
    |> assign(:event, %Event{})
    |> assign(
      :events,
      list_events(socket.assigns.filter_month.year, socket.assigns.filter_month.month)
    )
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    socket
    |> assign(:page_title, "Show Event")
    |> assign(:event, AgendaService.get_event!(id))
    |> assign(
      :events,
      list_events(socket.assigns.filter_month.year, socket.assigns.filter_month.month)
    )
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    event = AgendaService.get_event!(id)
    {:ok, _} = AgendaService.delete_event(event)
    Panel.set_tab(:panel, socket.assigns.view)

    {:noreply,
     socket
     |> assign(live_action: :index)
     |> assign(
       events: list_events(socket.assigns.filter_month.year, socket.assigns.filter_month.month)
     )
     |> put_flash(:warning, "Event deleted successfully")
     |> push_patch(to: Routes.event_index_path(socket, :index))}
  end

  def handle_event("modal_close", _, socket), do: {:noreply, assign(socket, live_action: :index)}

  def handle_event("strict_mode", _, socket),
    do: {:noreply, assign(socket, :strict, !socket.assigns.strict)}

  def handle_event("prev_month", _, socket) do
    shift_filter_month(socket, -1)
  end

  def handle_event("next_month", _, socket) do
    shift_filter_month(socket, 1)
  end

  def handle_event("switch_tab", %{"index" => index_str}, socket) do
    index = String.to_integer(index_str)
    Panel.set_tab(:panel, index)
    {:noreply, assign(socket, view: index)}
  end

  def shift_filter_month(socket, months) do
    filter_month = Timex.shift(socket.assigns.filter_month, months: months)
    Panel.set_tab(:panel, socket.assigns.view)

    {:noreply,
     socket
     |> assign(filter_month: filter_month)
     |> assign(events: list_events(filter_month.year, filter_month.month))}
  end

  defp list_events(year, month) do
    AgendaService.list_events_by(:month, year, month)
  end
end
