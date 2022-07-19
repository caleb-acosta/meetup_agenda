defmodule MeetupAgendaWeb.EventLive.Index do
  use Surface.LiveView

  alias MeetupAgenda.AgendaService
  alias MeetupAgenda.AgendaService.Event
  alias Surface.Components.LivePatch
  alias SurfaceBulma.{Panel, Modal, Button, Form.Checkbox}
  alias SurfaceBulma.Panel.{Tab, Tab.TabItem}
  alias MeetupAgendaWeb.Router.Helpers, as: Routes
  alias MeetupAgendaWeb.EventLive.{Show, FormComponent, Agenda, Calendar}

  data(today, :integer, default: Timex.today())
  data(events, :list, default: [])
  data(event, :map, default: %Event{})
  data(strict, :boolean, default: false)
  data(filter_month, :map, default: %{month: Timex.today().month, year: Timex.today().year})

  @impl true
  def handle_params(params, _url, socket) do
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

    {:noreply,
     assign(socket,
       events: list_events(socket.assigns.filter_month.year, socket.assigns.filter_month.month)
     )}
  end

  def handle_event("modal_close", _, socket), do: {:noreply, assign(socket, live_action: :index)}

  def handle_event("strict_mode", _, socket),
    do: {:noreply, assign(socket, :strict, !socket.assigns.strict)}

  def handle_event("prev_month", _, socket) do
    filter_month =
      cond do
        socket.assigns.filter_month.month == 1 ->
          %{month: 12, year: socket.assigns.filter_month.year - 1}

        true ->
          Map.update!(socket.assigns.filter_month, :month, &(&1 - 1))
      end

    {:noreply,
     socket
     |> assign(filter_month: filter_month)
     |> assign(events: list_events(filter_month.year, filter_month.month))}
  end

  def handle_event("next_month", _, socket) do
    filter_month =
      cond do
        socket.assigns.filter_month.month == 12 ->
          %{month: 1, year: socket.assigns.filter_month.year + 1}

        true ->
          Map.update!(socket.assigns.filter_month, :month, &(&1 + 1))
      end

    {:noreply,
     socket
     |> assign(filter_month: filter_month)
     |> assign(events: list_events(filter_month.year, filter_month.month))}
  end

  def handle_event("switch_tab", %{"index" => index_str}, socket) do
    Panel.set_tab(:panel, String.to_integer(index_str))
    {:noreply, socket}
  end

  defp list_events(year, month) do
    AgendaService.list_events_by(:month, year, month)
  end
end
