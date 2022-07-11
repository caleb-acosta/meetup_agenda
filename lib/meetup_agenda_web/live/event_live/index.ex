defmodule MeetupAgendaWeb.EventLive.Index do
  use MeetupAgendaWeb, :live_view

  alias MeetupAgenda.AgendaService
  alias MeetupAgenda.AgendaService.Event

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :events, list_events())}
  end

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
    |> assign(:event, %Event{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Events")
    |> assign(:event, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    event = AgendaService.get_event!(id)
    {:ok, _} = AgendaService.delete_event(event)

    {:noreply, assign(socket, :events, list_events())}
  end

  defp list_events do
    AgendaService.list_events()
  end
end
