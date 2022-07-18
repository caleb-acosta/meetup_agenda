defmodule MeetupAgendaWeb.EventLive.FormComponent do
  use Surface.LiveComponent

  alias MeetupAgenda.AgendaService
  alias MeetupAgenda.AgendaService.Event
  alias Surface.Components.Form
  alias Surface.Components.Form.{Label, Submit, ErrorTag, Select, TextInput}

  data changeset, :any, default: AgendaService.change_event(%Event{})
  prop action, :atom, default: :edit
  prop event, :map, default: %Event{event_date: Timex.today()}

  def handle_event("save", %{"event" => event_params}, socket) do
    save_event(socket, socket.assigns.action, order_params(event_params))
  end

  defp save_event(socket, :edit, event_params) do
    case AgendaService.update_event(socket.assigns.event, event_params) do
      {:ok, _event} ->
        {:noreply,
         socket
         |> put_flash(:info, "Event updated successfully")
         |> push_patch(to: "/events", live_action: :edit)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_event(socket, :new, event_params) do
    case AgendaService.create_event(event_params) do
      {:ok, _event} ->
        {:noreply,
         socket
         |> put_flash(:info, "Event created successfully")
         |> push_redirect(to: MeetupAgendaWeb.Router.Helpers.event_index_path(socket, :index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp order_params(%{
         "title" => title,
         "description" => description,
         "year" => year,
         "month" => month,
         "day" => day,
         "ordinal_day" => ordinal_day
       }) do
    %{
      title: title,
      description: description,
      event_date:
        create_date(
          String.to_integer(ordinal_day),
          String.to_integer(day),
          String.to_integer(month),
          String.to_integer(year)
        )
    }
  end

  defp create_date(ordinal_day, day, month, year) do
    Date.range(Timex.beginning_of_month(year, month), Timex.end_of_month(year, month))
    |> Enum.filter(&(Timex.weekday(&1) == day))
    |> Enum.at(ordinal_day - 1)
  end

  defp ordinal_weekday(event_date) do
    Date.range(Timex.beginning_of_month(event_date), Timex.end_of_month(event_date))
    |> Enum.filter(&(Timex.weekday(&1) == Timex.weekday(event_date)))
    |> Enum.find_index(&(&1 == event_date))
    |> Kernel.+(1)
  end
end
