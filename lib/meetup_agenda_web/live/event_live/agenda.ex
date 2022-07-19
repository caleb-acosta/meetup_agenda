defmodule MeetupAgendaWeb.EventLive.Agenda do

  @moduledoc """
    Agenda View Component for MeetupAgenda.
  """

  use Surface.LiveComponent

  alias SurfaceBulma.Table
  alias SurfaceBulma.Table.Column
  alias Surface.Components.{LivePatch, Link}
  alias MeetupAgendaWeb.Router.Helpers, as: Routes

  prop events, :list
end
