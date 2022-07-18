defmodule MeetupAgendaWeb.EventLive.Index do
  use Surface.LiveView

  alias MeetupAgenda.AgendaService
  alias MeetupAgenda.AgendaService.Event
  alias Surface.Components.{LivePatch, Link}
  alias SurfaceBulma.{Panel, Modal, Table}
  alias SurfaceBulma.Panel.{Tab, Tab.TabItem}
  alias SurfaceBulma.Table.{Column}
  alias MeetupAgendaWeb.Router.Helpers, as: Routes
  alias MeetupAgendaWeb.EventLive.FormComponent
  alias MeetupAgendaWeb.EventLive.Show

  data(today, :integer, default: Timex.today())
  data(events, :list, default: [])
  data(event, :map, default: %Event{})

  data(filter_month, :map,
    default: %{month: Timex.today().month |> Timex.month_name(), year: Timex.today().year}
  )
   
  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Event")
    |> assign(:event, AgendaService.get_event!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Event")
    |> assign(:event, %Event{event_date: Timex.today()})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Events")
    |> assign(:event, %Event{})
    |> assign(:events, list_events())
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    socket
    |> assign(:page_title, "Show Event")
    |> assign(:event, AgendaService.get_event!(id))
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    event = AgendaService.get_event!(id)
    {:ok, _} = AgendaService.delete_event(event)

    {:noreply, assign(socket, :events, list_events())}
  end

  def handle_event("modal_close", _, socket), do: {:noreply, assign(socket, live_action: :index)}

  def handle_event("switch_tab", %{"index" => index_str}, socket) do
    Panel.set_tab(:panel, String.to_integer(index_str))
    {:noreply, socket}
  end

  defp list_events do
    AgendaService.list_events()
  end
end
