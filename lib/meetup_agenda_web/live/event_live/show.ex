defmodule MeetupAgendaWeb.EventLive.Show do
  
  @moduledoc """
  Show Surface Component for MeetupAgenda.AgendaService.Event attributes.
  """

  use Surface.LiveComponent

  alias Surface.Components.{LivePatch, Link}
  alias MeetupAgendaWeb.Router.Helpers, as: Routes

  prop event, :map
end
