defmodule MeetupAgendaWeb.EventLive.Calendar do

  @moduledoc """
    Calendar View Component For MeetupAgenda.
  """

  use Surface.LiveComponent

  alias SurfaceBulma.Table
  alias SurfaceBulma.Table.Column
  alias Surface.Components.LivePatch
  alias MeetupAgendaWeb.Router.Helpers, as: Routes

  prop events, :list
  prop month, :map

  defp weeks_in_month(events, year, month) do
    Date.range(Timex.beginning_of_month(year, month), Timex.end_of_month(year, month))
    |> Enum.map(fn day ->
      {day, Enum.filter(events, &(&1.event_date == day))}
    end)
    |> Enum.chunk_by(&Timex.week_of_month(elem(&1, 0)))
    |> Enum.map(fn week ->
      Enum.reduce(week, %{}, &Map.put(&2, Timex.weekday(elem(&1, 0)), &1))
    end)
  end
end
